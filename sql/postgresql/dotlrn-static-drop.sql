--
--  Copyright (C) 2001, 2002 MIT
--
--  This file is part of dotLRN.
--
--  dotLRN is free software; you can redistribute it and/or modify it under the
--  terms of the GNU General Public License as published by the Free Software
--  Foundation; either version 2 of the License, or (at your option) any later
--  version.
--
--  dotLRN is distributed in the hope that it will be useful, but WITHOUT ANY
--  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
--  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
--  details.
--

--
-- The dotlrn applet for the STATIC data portlet
--
-- arjun@openforce.net
--
-- $Id$
--
-- PostGreSQL port samir@symphinity.com 11 July 2002
--
create function inline_0()
returns integer as '
begin

	perform acs_sc_impl__delete(
	   ''dotlrn_applet'',		-- impl_contract_name
     ''dotlrn_static''		-- impl_name
  );


-- delete all the hooks

-- GetPrettyName
	perform  acs_sc_impl_alias__delete (
	    ''dotlrn_applet'',
	    ''dotlrn_static'',
	    ''GetPrettyName''
 );


	-- AddApplet
	perform  acs_sc_impl_alias__delete (
	       ''dotlrn_applet'',
	       ''dotlrn_static'',
	       ''AddApplet''
	);



	-- RemoveApplet
	perform  acs_sc_impl_alias__delete (
	       ''dotlrn_applet'',
	       ''dotlrn_static'',
	       ''RemoveApplet''
	);

	-- AddAppletToCommunity
	perform  acs_sc_impl_alias__delete (
	       ''dotlrn_applet'',
	       ''dotlrn_static'',
	       ''AddAppletToCommunity''
	);


	-- RemoveAppletFromCommunity
	perform  acs_sc_impl_alias__delete (
	       ''dotlrn_applet'',
	       ''dotlrn_static'',
	       ''RemoveAppletFromCommunity''
	);

	-- AddUser
	perform  acs_sc_impl_alias__delete (
	       ''dotlrn_applet'',
	       ''dotlrn_static'',
	       ''AddUser''
	);

	-- RemoveUser
	perform  acs_sc_impl_alias__delete (
	       ''dotlrn_applet'',
	       ''dotlrn_static'',
	       ''RemoveUser''
	);

	-- AddUserToCommunity
	perform  acs_sc_impl_alias__delete (
	       ''dotlrn_applet'',
	       ''dotlrn_static'',
	       ''AddUserToCommunity''
	);

	-- RemoveUserFromCommunity
	perform  acs_sc_impl_alias__delete (
	       ''dotlrn_applet'',
	       ''dotlrn_static'',
	       ''RemoveUserFromCommunity''
	);

    -- AddPortlet
	perform  acs_sc_impl_alias__delete (
        	''dotlrn_applet'',									-- impl_contract_name
	        ''dotlrn_static'',									-- impl_name
 	      	''AddPortlet''  										-- impl_operation_name
    	);
	
    -- RemovePortlet
	perform  acs_sc_impl_alias__delete (
     	   	''dotlrn_applet'',
     	  	''dotlrn_static'',
       	 	''RemovePortlet''
    );

    -- Clone
	perform  acs_sc_impl_alias__delete (
        	''dotlrn_applet'',
        	''dotlrn_static'',
        	''Clone''
    	);


	-- Remove the binding
	perform acs_sc_binding__delete (
	    ''dotlrn_applet'',
	    ''dotlrn_static''
		);

	RAISE NOTICE '' Finished deleting dotlrn-static sc....'';
	
return 0;
end;' language 'plpgsql';

select inline_0();

drop function inline_0();

