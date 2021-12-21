package workflows

CI: _#baseWorkflow & {
	name: "CI"
	on: {
		workflow_dispatch: {}
	}
	jobs: job1: {
		name: "Test SSF Installation"
		steps: [{
			uses: "actions/checkout@v2"
		}, {
			name: "Install CUE"
			uses: "cue-lang/setup-cue@v0.0.1"
			with: version: "v0.4.1-beta.6"
		}, {
			name: "Regenerate YAML from CUE"
			"working-directory": ".github/workflows"
			run: "cue cmd genworkflows"
		}, {
			name: "Check commit is clean"
			run:  #"test -z "$(git status --porcelain)" || (git status; git diff; false)"#
		}, {
			name: "Start minikube"
			run: """
				make setup-minikube

				"""
		}, {
			name: "Try the cluster !"
			run:  "kubectl get pods -A"
		}, {
			name: "Deploy SSF to minikube"
			run: """
				make setup-tekton-chains
				make setup-kyverno

				"""
		}, {
			name: "Generate temp keys"
			run: """
				make tekton-generate-keys

				"""
		}, {
			name: "Run test pipeline"
			run: """
				./examples/buildpacks/buildpacks.sh
				export DOCKER_IMG=$(tkn pr describe --last -o jsonpath='{.spec.params[?(@.name==\"APP_IMAGE\")].value}')
				tkn pr logs --last -f
				sleep 60
				docker run --rm gcr.io/go-containerregistry/crane ls $DOCKER_IMG
				tkn tr describe --last -o json | jq -r '.metadata.annotations[\"chains.tekton.dev/signed\"]'
				cosign verify --key k8s://tekton-chains/signing-secrets ${DOCKER_IMG}
				cosign verify-attestation --key k8s://tekton-chains/signing-secrets ${DOCKER_IMG}

				"""
		}]
	}
}
