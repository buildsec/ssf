// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/kyverno/kyverno/api/kyverno/v1

package v1

import rbacv1 "k8s.io/api/rbac/v1"

// UserInfo contains information about the user performing the operation.
#UserInfo: {
	// Roles is the list of namespaced role names for the user.
	// +optional
	roles?: [...string] @go(Roles,[]string)

	// ClusterRoles is the list of cluster-wide role names for the user.
	// +optional
	clusterRoles?: [...string] @go(ClusterRoles,[]string)

	// Subjects is the list of subject names like users, user groups, and service accounts.
	// +optional
	subjects?: [...rbacv1.#Subject] @go(Subjects,[]rbacv1.Subject)
}