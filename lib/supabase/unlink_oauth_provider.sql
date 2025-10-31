-- Supabase SQL: RPC to unlink an OAuth provider from the current authenticated user
-- Usage: Call this function as an authenticated user via the client RPC:
-- await supabase.rpc('unlink_oauth_provider', { provider: 'google' });
-- Notes:
-- - This function deletes the identity row for the calling user and the given provider.
-- - It requires the caller to be authenticated. Make sure your RLS/policies allow
--   executing the function for the "authenticated" role (GRANT EXECUTE is added below).
-- - Deleting the last identity may make it impossible to sign in using OAuth for that user
--   unless they also have an email/password or another identity. Use with caution.

create or replace function public.unlink_oauth_provider(p_provider text)
returns json language plpgsql stable security definer as $$
declare
  v_user uuid := auth.uid();
  v_deleted int := 0;
begin
  if v_user is null then
    return json_build_object('success', false, 'error', 'not_authenticated');
  end if;

  -- Delete the identity for this user and provider
  delete from auth.identities
  where user_id = v_user and provider = p_provider
  returning 1 into v_deleted;

  if v_deleted > 0 then
    return json_build_object('success', true, 'deleted', v_deleted);
  else
    return json_build_object('success', false, 'error', 'not_found');
  end if;
exception when others then
  return json_build_object('success', false, 'error', sqlerrm);
end;
$$;

-- Grant execute to the authenticated role so logged-in users can call this RPC.
grant execute on function public.unlink_oauth_provider(text) to authenticated;

-- Optionally: if you want to permit admin use, grant to service_role or a custom role.
-- grant execute on function public.unlink_oauth_provider(text) to service_role;

-- After running this SQL in the Supabase SQL editor, the frontend can call:
-- await supabase.rpc('unlink_oauth_provider', params: { provider: 'google' });
