defmodule Cog.Queries.Permission do
  use Cog.Queries


  def names do
    from p in Cog.Models.Permission,
    join: b in assoc(p, :bundle),
    order_by: [b.name, p.name],
    select: [b.name, p.name]
  end

  def from_full_name(full_name) do
    {bundle_name, name} = Permission.split_name(full_name)

    from p in Cog.Models.Permission,
    join: b in assoc(p, :bundle),
    where: p.name == ^name and
           b.name == ^bundle_name,
    select: p
  end

  def from_bundle_name(bundle_name) do
    from p in Cog.Models.Permission,
    join: b in assoc(p, :bundle),
    where: b.name == ^bundle_name,
    select: p
  end

  def from_group_roles(rolename) do
    from gr in Cog.Models.GroupRole,
    join: r in assoc(gr, :role),
    where: r.name == ^rolename,
    select: gr,
    preload: [:group]
  end

  def from_user_roles(rolename) do
    from ur in Cog.Models.UserRole,
    join: r in assoc(ur, :role),
    where: r.name == ^rolename,
    select: ur,
    preload: [:user]
  end

  def directly_granted_to_user(user_id) do
    from u in Cog.Models.User,
    join: p in assoc(u, :permissions),
    where: u.id == ^user_id,
    select: p
  end

  def directly_granted_to_group(group_id) do
    from g in Cog.Models.Group,
    join: p in assoc(g, :permissions),
    where: g.id == ^group_id,
    select: p
  end

  def directly_granted_to_role(role_id) do
    from r in Cog.Models.Role,
    join: p in assoc(r, :permissions),
    where: r.id == ^role_id,
    select: p
  end
end
