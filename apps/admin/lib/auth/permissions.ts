export type AdminRole = "owner" | "admin" | "editor" | "support" | "viewer";

export type Permission =
  | "dashboard.read"
  | "users.read"
  | "users.manage"
  | "admins.read"
  | "admins.manage"
  | "premium.read"
  | "premium.manage"
  | "requests.read"
  | "requests.manage"
  | "catalog.read"
  | "catalog.manage"
  | "content.read"
  | "content.manage"
  | "content.publish"
  | "translations.read"
  | "translations.manage"
  | "audit.read"
  | "settings.read"
  | "settings.manage";

const permissionsByRole: Record<AdminRole, Permission[]> = {
  owner: [
    "dashboard.read",
    "users.read",
    "users.manage",
    "admins.read",
    "admins.manage",
    "premium.read",
    "premium.manage",
    "requests.read",
    "requests.manage",
    "catalog.read",
    "catalog.manage",
    "content.read",
    "content.manage",
    "content.publish",
    "translations.read",
    "translations.manage",
    "audit.read",
    "settings.read",
    "settings.manage",
  ],
  admin: [
    "dashboard.read",
    "users.read",
    "users.manage",
    "admins.read",
    "premium.read",
    "premium.manage",
    "requests.read",
    "requests.manage",
    "catalog.read",
    "catalog.manage",
    "content.read",
    "content.manage",
    "content.publish",
    "translations.read",
    "translations.manage",
    "audit.read",
    "settings.read",
    "settings.manage",
  ],
  editor: [
    "dashboard.read",
    "catalog.read",
    "catalog.manage",
    "content.read",
    "content.manage",
    "content.publish",
    "translations.read",
    "translations.manage",
    "audit.read",
    "settings.read",
  ],
  support: [
    "dashboard.read",
    "users.read",
    "premium.read",
    "requests.read",
    "requests.manage",
    "catalog.read",
    "content.read",
    "translations.read",
    "audit.read",
    "settings.read",
  ],
  viewer: [
    "dashboard.read",
    "users.read",
    "premium.read",
    "requests.read",
    "catalog.read",
    "content.read",
    "translations.read",
    "audit.read",
    "settings.read",
  ],
};

export function hasPermission(role: AdminRole, permission: Permission) {
  return permissionsByRole[role].includes(permission);
}

export function canManageAdminTarget(
  actorRole: AdminRole,
  targetRole: AdminRole,
) {
  if (actorRole === "owner") return true;
  if (actorRole !== "admin") return false;
  return targetRole !== "owner" && targetRole !== "admin";
}
