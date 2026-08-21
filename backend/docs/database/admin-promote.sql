-- Promotes a user to the Admin role (dev helper).
--
-- "Roles"."Name" stores the RoleType enum as an INT:
--   1 = Customer, 2 = Admin, 3 = SuperAdmin, 4 = Support, 5 = Finance
--
-- The role claim is baked into the JWT at login, so the user MUST log in
-- again after promotion for the new role to take effect.

UPDATE "Users"
SET "RoleId" = (SELECT "Id" FROM "Roles" WHERE "Name" = 2)
WHERE "Email" = '<email>';

-- To demote back to Customer:
-- UPDATE "Users"
-- SET "RoleId" = (SELECT "Id" FROM "Roles" WHERE "Name" = 1)
-- WHERE "Email" = '<email>';
