--
-- The dotlrn applet for the STATIC data portlet
-- copyright 2001, OpenForce
-- distributed under GPL v2.0
--
--
-- arjun@openforce.net
--
-- $Id$
--

declare
	foo integer;
begin
	-- create the implementation
	foo := acs_sc_impl.new (
		'dotlrn_applet',
		'dotlrn_static',
		'dotlrn_static'
	);

	-- add all the hooks

	-- GetPrettyName
	foo := acs_sc_impl.new_alias (
	       'dotlrn_applet',
	       'dotlrn_static',
	       'GetPrettyName',
	       'dotlrn_static::get_pretty_name',
	       'TCL'
	);

	-- AddApplet
	foo := acs_sc_impl.new_alias (
	       'dotlrn_applet',
	       'dotlrn_static',
	       'AddApplet',
	       'dotlrn_static::add_applet',
	       'TCL'
	);


	-- AddAppletToCommunity
	foo := acs_sc_impl.new_alias (
	       'dotlrn_applet',
	       'dotlrn_static',
	       'AddAppletToCommunity',
	       'dotlrn_static::add_applet_to_community',
	       'TCL'
	);



	-- RemoveApplet
	foo := acs_sc_impl.new_alias (
	       'dotlrn_applet',
	       'dotlrn_static',
	       'RemoveApplet',
	       'dotlrn_static::remove_applet',
	       'TCL'
	);

	-- AddUser
	foo := acs_sc_impl.new_alias (
	       'dotlrn_applet',
	       'dotlrn_static',
	       'AddUser',
	       'dotlrn_static::add_user',
	       'TCL'
	);

	-- AddUserToCommunity
	foo := acs_sc_impl.new_alias (
	       'dotlrn_applet',
	       'dotlrn_static',
	       'AddUserToCommunity',
	       'dotlrn_static::add_user_to_community',
	       'TCL'
	);

	-- RemoveUser
	foo := acs_sc_impl.new_alias (
	       'dotlrn_applet',
	       'dotlrn_static',
	       'RemoveUser',
	       'dotlrn_static::remove_user',
	       'TCL'
	);

	-- RemoveUserFromCommunity
	foo := acs_sc_impl.new_alias (
	       'dotlrn_applet',
	       'dotlrn_static',
	       'RemoveUserFromCommunity',
	       'dotlrn_static::remove_user_from_community',
	       'TCL'
	);

	-- Add the binding
	acs_sc_binding.new (
	    contract_name => 'dotlrn_applet',
	    impl_name => 'dotlrn_static'
	);
end;
/
show errors

