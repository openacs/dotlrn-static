#
#  Copyright (C) 2001, 2002 OpenForce, Inc.
#
#  This file is part of dotLRN.
#
#  dotLRN is free software; you can redistribute it and/or modify it under the
#  terms of the GNU General Public License as published by the Free Software
#  Foundation; either version 2 of the License, or (at your option) any later
#  version.
#
#  dotLRN is distributed in the hope that it will be useful, but WITHOUT ANY
#  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
#  details.
#

#
# Procs for DOTLRN static Applet
# Copyright 2001 OpenForce, inc.
# Distributed under the GNU GPL v2
#
# arjun@openforce.net
#
# $Id$

ad_library {
    
    Procs for the dotLRN Static applet
    
    @author arjun@openforce.net
}

namespace eval dotlrn_static {
    
    ad_proc -private my_package_key {
    } {
        return "dotlrn-static"
    }

    ad_proc -public applet_key {} {
	get the applet key
    } {
	return "dotlrn_static"
    }

    ad_proc -public package_key {
    } {
	Get the package_key this applet deals with. 

        This is _unlike_ a package like bboard since there's
        no "static" package but a combined  "static-portlet" 
        package. I named it "static-portlet" instead of 
        "static" since it's tied to (new-portal) so strongly
    } {
	return "static-portlet"
    }

    ad_proc -public get_pretty_name {
    } {
	returns the pretty name
    } {
	return "dotLRN static data"
    }

    ad_proc -public add_applet {
    } {
	Add the static applet to dotlrn - for one-time init
	Must be repeatable!
    } {
        # FIXME: won't work with multiple dotlrn instances
        # aks - trying one mounting of static under /dotlrn (like calendar)
        # Use the package_key for the -url param - "/" are not allowed!
        if {![dotlrn::is_package_mounted -package_key [my_package_key]]} {
            dotlrn_applet::mount  -package_key [package_key]
        }

        dotlrn_applet::add_applet_to_dotlrn -applet_key [applet_key]
    }

    ad_proc -public add_applet_to_community {
	community_id
    } {
	Add the static applet to a dotlrn community
    } {
        set community_type [dotlrn_community::get_community_type_from_community_id $community_id]
        set portal_id [dotlrn_community::get_portal_id -community_id $community_id]

        # If i'm in a class, add a portlet called "class (pn) info"
        # if I'm in a community, add a portlet called "community (pn) info"
        # or if I'm in a subcomm, "subcomm (pn) info"
        if {$community_type == "dotlrn_club"} {

            set content_id [static_portal_content::new \
                    -package_id $community_id \
                    -content " " \
                    -pretty_name "[dotlrn::parameter clubs_pretty_name] Info"
            ]
        
            static_portal_content::add_to_portal -content_id $content_id -portal_id $portal_id
    
        } elseif {$community_type == "dotlrn_community"} {

            set content_id [static_portal_content::new \
                -package_id $community_id \
                -content " " \
                -pretty_name "[dotlrn::parameter subcommunities_pretty_name] Info"
            ]
        
            static_portal_content::add_to_portal -content_id $content_id -portal_id $portal_id 
        } else {
            set content_id [static_portal_content::new \
                -package_id $community_id \
                -content " " \
                -pretty_name "[dotlrn::parameter class_instances_pretty_name] Info"
            ]
        
            static_portal_content::add_to_portal -content_id $content_id -portal_id $portal_id
        } 

        if {[dotlrn_community::dummy_comm_p -community_id $community_id]} {
            return
        }

        # the non-member page gets the same static portlet
        set n_p_id [dotlrn_community::get_non_member_portal_id -community_id $community_id]
        static_portal_content::add_to_portal -content_id $content_id -portal_id $n_p_id

        # set up the DS for the admin page
        set admin_portal_id [dotlrn_community::get_admin_portal_id -community_id $community_id]
        static_admin_portlet::add_self_to_page -portal_id $admin_portal_id -package_id $community_id
    }

    ad_proc -public remove_applet_from_community {
	community_id
    } {
	Remove static applet from a dotlrn community
    } {
        set admin_portal_id [dotlrn_community::get_admin_portal_id -community_id $community_id]
        static_admin_portlet::remove_self_from_page -portal_id $admin_portal_id 

        set n_p_id [dotlrn_community::get_non_member_portal_id -community_id $community_id]
        static_portal_content::remove_all_from_portal -portal_id $n_p_id
        
        # remove all static content 
        set portal_id [dotlrn_community::get_portal_id -community_id $community_id]
        static_portal_content::remove_all_from_portal -portal_id $portal_id
    }


    ad_proc -public remove_applet {
	package_id
    } {
	remove the applet from dotlrn
    } {
    }

    ad_proc -public add_user {
	community_id
    } {
	Called when the user is initially added as a dotlrn user.
	For one-time init stuff
	
    } {
	
    }

    ad_proc -public remove_user {
        user_id
    } {
    } {
    }

    ad_proc -public add_user_to_community {
	community_id
	user_id
    } {
	Add a user to a specific dotlrn community
    } {
    }

    ad_proc -public remove_user_from_community {
	community_id
	user_id
    } {
	Remove a user from a community
    } {
    }

    ad_proc -public add_portlet {
        args
    } {
        A helper proc to add the underlying portlet to the given portal. 
        
        @param args a list-ified array of args defined in add_applet_to_community
    } {
        ns_log notice "** Error in [get_pretty_name]: 'add_portlet' not implemented!"
        ad_return_complaint 1  "Please notifiy the administrator of this error:
        ** Error in [get_pretty_name]: 'add_portlet' not implemented!"
    }

    ad_proc -public remove_portlet {
        args
    } {
        A helper proc to remove the underlying portlet from the given portal. 
        
        @param args a list-ified array of args defined in remove_applet_from_community
    } {
        ns_log notice "** Error in [get_pretty_name]: 'remove_portlet' not implemented!"
        ad_return_complaint 1  "Please notifiy the administrator of this error:
        ** Error in [get_pretty_name]: 'remove_portlet' not implemented!"
    }

    ad_proc -public clone {
        old_community_id
        new_community_id
    } {
        Clone this applet's content from the old community to the new one
    } {
        ns_log notice "** Error in [get_pretty_name] 'clone' not implemented!"
        ad_return_complaint 1  "Please notifiy the administrator of this error:
        ** Error in [get_pretty_name]: 'clone' not implemented!"
    }

}
