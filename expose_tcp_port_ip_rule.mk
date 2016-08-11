#
# iptables configuration makefile script
#
# Reference Guide - https://www.gnu.org/software/make/manual/make.html

#
# We use this to enable communication with the tcp port used by openebs daemon
# In other words, once the tcp port is enabled use curl, postmaster etc to 
# as http clients & keep doing your endless testing.
#


#
# This is done to avoid conflict with a file of same name as the targets
# mentioned in this makefile.
#
.PHONY: run apply apply_from_scratch _flush _allow_ssh_on22 _allow_custom_tcp_port _set_default_policies _set_lo_access _accept_est_conn _save_settings _list_rules


#
# The value(s) will be provided at runtime
#
port           :=


#
# Default target.
# NOTE - This has to be the FIRST target !!!!!!!
#
run: _allow_custom_tcp_port _list_rules 

#
# Apply custom tcp port that will be persist after reboots
#
apply: _allow_custom_tcp_port _save_settings _list_rules 


#
# Apply basic rules from scratch
# NOTE - DEVELOPMENT ONLY -- Will flush existing rules !!!!
#
apply_from_scratch: _flush _allow_ssh_on22 _allow_custom_tcp_port _set_default_policies _set_lo_access _accept_est_conn _save_settings _list_rules


#
# Flush all current rules from iptables
# s.t. adding a rule will be done from a clean state
#
_flush:
	@iptables -F


#
# Allow SSH connections on tcp port 22
# This is essential when working on remote servers via SSH 
# to prevent locking yourself out of the system
#
_allow_ssh_on22:
	@iptables -A INPUT -p tcp --dport 22 -j ACCEPT


#
# Allow connection on tcp port provided by user
#
_allow_custom_tcp_port:
ifdef port
	@iptables -A INPUT -p tcp --dport $(port) -j ACCEPT
endif


#
# Set default policies for INPUT, FORWARD and OUTPUT chains
#
_set_default_policies:
	@iptables -P INPUT DROP
	@iptables -P FORWARD DROP
	@iptables -P OUTPUT ACCEPT

#
# Set access for localhost
#
_set_lo_access:
	@iptables -A INPUT -i lo -j ACCEPT

#
# Accept packets belonging to established and related connections
#
_accept_est_conn:
	@iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#
# Save settings
# i.e. on reboot these rules are reloaded
#
_save_settings:
	@iptables-save

#
# List rules
#
_list_rules:
	@iptables -L -v
