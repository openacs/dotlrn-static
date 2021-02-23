#
#  Copyright (C) 2001, 2002 MIT
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

ad_library {

    Procs for the dotLRN Static applet

    @author arjun@openforce.net
    @cvs-id $Id$
}

namespace eval dotlrn_static {

    ad_proc -private my_package_key {
    } {
        return "dotlrn-static"
    }

    ad_proc -public applet_key {} {
        What's my key?
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
        return "[_ [pretty_name_key]]"
    }

    ad_proc -private pretty_name_key {

    } {
        return "dotlrn-static.Static_HTML_Data"
    }

    ad_proc -public add_applet {
    } {
        Add the static applet to dotlrn - for one-time init
        Must be repeatable!
    } {

        if {![dotlrn_applet::applet_exists_p -applet_key [applet_key]]} {

            db_transaction {
                dotlrn_applet::mount \
                    -package_key [package_key] \
                    -url [package_key] \
                    -pretty_name "#[pretty_name_key]#"

                dotlrn_applet::add_applet_to_dotlrn \
                    -applet_key [applet_key] \
                    -package_key [my_package_key]
            }

        }
    }

    ad_proc -public remove_applet {} {
        Remove the applet from dotlrn
    } {
        db_transaction {
            set package_url [site_node::get_package_url -package_key [package_key]]
            if { $package_url ne "" } {
                set node_id [site_node::get_node_id -url $package_url]
                site_node::unmount -node_id $node_id
                site_node::delete -node_id $node_id -delete_subnodes
            }
            dotlrn_applet::remove_applet_from_dotlrn -applet_key [applet_key]
        }
    }

    ad_proc -public add_applet_to_community {
        community_id
    } {
        Add the static applet to a dotlrn community
    } {

        # set up admin portlet
        set admin_portal_id [dotlrn_community::get_admin_portal_id -community_id $community_id]
        static_admin_portlet::add_self_to_page \
            -portal_id $admin_portal_id \
            -package_id $community_id

        set portal_id [dotlrn_community::get_portal_id -community_id $community_id]

        set args [ns_set create]

        set template_id [portal::get_portal_template_id $portal_id]

        if {$template_id eq ""} {

            set template_id $portal_id
        }

        ns_set put $args "package_id" $community_id
        ns_set put $args "template_id" $template_id

        # quit if new_content_id is empty, this means the template
        # portal does not have custom portlets
        if { [set new_content_id [add_portlet_helper $portal_id $args]] eq "" } {
            return
        }

        # the non-member portal uses the returned content_id from
        # the main page above to create a linked static portlet
        set n_p_id [dotlrn_community::get_non_member_portal_id \
                        -community_id $community_id]

        # clear the template_id
        ns_set update $args "template_id" ""
        ns_set put $args "content_id" $new_content_id

        add_portlet_helper $n_p_id $args

        # replace the existing content with the community's description
        # doesn't matter if we use the comm's portal_id or the
        # non member portal_id here since they point to the same content_id
        static_portal_content::update \
            -content_id $new_content_id \
            -content [dotlrn_community::get_community_description \
                          -community_id $community_id] \
            -pretty_name [static_portal_content::get_pretty_name -content_id $new_content_id] \
            -portal_id $n_p_id
    }

    ad_proc -public remove_applet_from_community {
        community_id
    } {
        Remove static applet from a dotlrn community
    } {
        ad_return_complaint 1 "[applet_key] remove_applet not implemented!"
    }

    ad_proc -private add_user {
        community_id
    } {
        Called when the user is initially added as a dotlrn user.
    } {
        # noop
    }

    ad_proc -private remove_user {
        user_id
    } {
    } {
        # noop
    }

    ad_proc -private add_user_to_community {
        community_id
        user_id
    } {
        Add a user to a specific dotlrn community
    } {
        # noop
    }

    ad_proc -private remove_user_from_community {
        community_id
        user_id
    } {
        Remove a user from a community. Since this applet is not shown
        on a user's portal, no action is required here.
    } {
        # noop
    }

    ad_proc -public add_portlet {
        portal_id
    } {
        A helper proc to add the underlying portlet to the given portal.

        @param portal_id
        @return element_id if added to the portal
    } {
        set type [dotlrn::get_type_from_portal_id -portal_id $portal_id]
        set package_id 0

        if {$type eq "user"} {
            # do nothing for the user portal template
            return
        } elseif {$type eq "dotlrn_club"} {
            # for clubs
            # Used by en_US messages below
            set clubs_pretty_name [dotlrn::parameter -name clubs_pretty_name]
            set pretty_name "#dotlrn-static.community_info_portlet_pretty_name#"
            set content_id [static_portal_content::new \
                                -package_id $package_id \
                                -content "$pretty_name" \
                                -pretty_name "$pretty_name"
            ]
        } elseif {$type eq "dotlrn_community"} {
            # for subgroups
            # Used by en_US messages below
            set subcommunities_pretty_name [dotlrn::parameter -name subcommunities_pretty_name]
            set pretty_name "#dotlrn-static.subcommunity_info_portlet_pretty_name#"
            set content_id [static_portal_content::new \
                                -package_id $package_id \
                                -content  "$pretty_name" \
                                -pretty_name "$pretty_name"
            ]
        } else {
            # for class instances
            # Used by en_US messages below
            set class_instances_pretty_name [dotlrn::parameter -name class_instances_pretty_name]
            set pretty_name "#dotlrn-static.class_info_portlet_pretty_name#"
            set content_id [static_portal_content::new \
                -package_id $package_id \
                -content "$pretty_name" \
                -pretty_name "$pretty_name"
            ]
        }

        set args [ns_set create]
        ns_set put $args package_id $package_id
        ns_set put $args content_id $content_id

        return [add_portlet_helper $portal_id $args]
    }

    ad_proc -public add_portlet_helper {
        portal_id
        args
    } {
        @param portal_id
        @param args
        @return element_id if added to the portal
    } {

        return [static_portal_content::add_to_portal \
                    -portal_id $portal_id \
                    -package_id [ns_set get $args "package_id"] \
                    -content_id [ns_set get $args "content_id"] \
                    -template_id [ns_set get $args "template_id"]]
    }

    ad_proc -public remove_portlet {
        portal_id
        element_id
        args
    } {
        A helper proc to remove the underlying portlet from the given portal.

        @param portal_id
        @param element_id
        @param args a list-ified array of args defined in remove_applet_from_community
    } {
        static_portlet::remove_self_from_page $portal_id $element_id
    }

    ad_proc -public clone {
        old_community_id
        new_community_id
    } {
        Clone this applet's content from the old community to the new one
    } {
        ns_log notice "Cloning [get_pretty_name]"
        static_portal_content::clone \
            -portal_id [dotlrn_community::get_portal_id \
                            -community_id $new_community_id] \
            -package_id $new_community_id
    }

    ad_proc -private change_event_handler {
        community_id
        event
        old_value
        new_value
    } {
        listens for the following events:
    } {
    }
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
