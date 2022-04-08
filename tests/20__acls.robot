*** Settings ***
Resource    keywords.resource
Variables   ./vars.py
Suite Setup    Setup acl suite vars

*** Variables ***
${MID1}    unknown
${DOMSUFFIX}    dc\=x,dc\=y

*** Keywords ***
Setup acl suite vars
    ${val} =     Get server url    ${MID1}
    Set Suite Variable    ${surl}    ${val}

*** Test Cases ***
Bad user logon fails
    ${out}  ${err}  ${rc} =    Execute Command    podman exec -i ldapclient ldapwhoami -H ${surl} -x -D 'uid\=baduser,${DOMSUFFIX}' -w 'badpass'
    ...    return_stderr=${TRUE}    return_rc=${TRUE}
    Should Be Equal As Integers    ${rc}    49
    Should Be Equal    ${out}    ${EMPTY}
    Should Contain    ${err}    Invalid credentials

Admin bind succeedes
    ${out}  ${err}  ${rc} =    Execute Command    podman exec -i ldapclient ldapwhoami -H ${surl} -x -D 'uid\=${admuser},ou=People,${DOMSUFFIX}' -w '${admpass}'
    ...    return_stderr=${TRUE}    return_rc=${TRUE}
    Should Be Equal As Integers    ${rc}    0
    Should Be Equal    ${out}    dn:uid\=${admuser},ou=People,${DOMSUFFIX}

Admin read access is configured
    ${out}  ${err}  ${rc} =    Execute Command    podman exec -i ldapclient ldapsearch -H ${surl} -LLL -x -D 'uid\=${admuser},ou=People,${DOMSUFFIX}' -w '${admpass}' -b ${DOMSUFFIX} userPassword\=* userPassword uid
    ...    return_stderr=${TRUE}    return_rc=${TRUE}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${out}    userPassword:
    Should Contain    ${out}    uid:

Anonymous bind succeedes
    ${out}  ${err}  ${rc} =    Execute Command    podman exec -i ldapclient ldapwhoami -H ${surl} -x -D '' -w ''
    ...    return_stderr=${TRUE}    return_rc=${TRUE}
    Should Be Equal As Integers    ${rc}    0
    Should Be Equal    ${out}    anonymous

Anonymous read access is configured
    ${out}  ${err}  ${rc} =    Execute Command    podman exec -i ldapclient ldapsearch -H ${surl} -LLL -x -D '' -w '' -b ${DOMSUFFIX} uid=admin userPassword uid
    ...    return_stderr=${TRUE}    return_rc=${TRUE}
    Should Be Equal As Integers    ${rc}    0
    Should Not Contain    ${out}    userPassword:
    Should Contain    ${out}    uid:

Ldapservice bind succeedes
    ${ldap_svcdn}    ${ldap_svcpass} =     Get ldapservice credentials    ${mid1}
    ${out}  ${err}  ${rc} =    Execute Command    podman exec -i ldapclient ldapwhoami -H ${surl} -x -D '${ldap_svcdn}' -w '${ldap_svcpass}'
    ...    return_stderr=${TRUE}    return_rc=${TRUE}
    Should Be Equal As Integers    ${rc}    0
    Should Be Equal    ${out}    dn:${ldap_svcdn}

Ldapservice read access is configured
    ${ldap_svcdn}    ${ldap_svcpass} =     Get ldapservice credentials    ${mid1}
    ${out}  ${err}  ${rc} =    Execute Command    podman exec -i ldapclient ldapsearch -H ${surl} -LLL -x -D '${ldap_svcdn}' -w '${ldap_svcpass}' -b ${DOMSUFFIX} uid=admin userPassword uid
    ...    return_stderr=${TRUE}    return_rc=${TRUE}
    Should Be Equal As Integers    ${rc}    0
    Should Not Contain    ${out}    userPassword:
    Should Contain    ${out}    uid:

Configuration database is not readable
    ${ldap_svcdn}    ${ldap_svcpass} =     Get ldapservice credentials    ${mid1}
    ${out}  ${err}  ${rc} =    Execute Command    podman exec -i ldapclient ldapsearch -H ${surl} -b cn\=config -s base -x -D '${ldap_svcdn}' -w '${ldap_svcpass}'
    ...    return_stderr=${TRUE}    return_rc=${TRUE}
    Should Be Equal As Integers    ${rc}    32

    ${out}  ${err}  ${rc} =    Execute Command    podman exec -i ldapclient ldapsearch -H ${surl} -b cn\=config -s base -x -D '' -w ''
    ...    return_stderr=${TRUE}    return_rc=${TRUE}
    Should Be Equal As Integers    ${rc}    32
