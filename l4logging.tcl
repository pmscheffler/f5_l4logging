when RULE_INIT priority 100 {
    set debuglevel 1
}

when CLIENT_ACCEPTED priority 100 {

    set HSL-POOL syslog-pool

    # could store the pool name in a Data Group
    # along with the protocol
    set HSL-POOL [class match -value "default" equals ]
    set hsl [HSL::open -proto UDP -pool $HSL-POOL]

    set client_logentry "Received a request from Client [IP::client_addr]:[TCP::client_port] to the VIP [IP::local_addr]:[TCP::local_port]"
    if {$debuglevel eq 1} 
        log local0. "$client_logentry"
}

when LB_SELECTED priority 100 {
    set lb_logentry "Server [IP::server_addr]:[TCP::server_port]" 
    if {debuglevel eq 1} 
        log local0. "$lb_logentry"
}

when LB_FAILED priority 100 {
    set lb_logentry "LB Selection Failed"
    if {debuglevel eq 1} 
        log local0. "$lb_logentry"
    
    HSL::send $hsl $lb_logentry
}

when SERVER_CONNECTED priority 100 {

    HSL::send $hsl "$client_logentry $lb_logentry"
    if {debuglevel eq 1} 
        log local0. "HSL sent"

}


