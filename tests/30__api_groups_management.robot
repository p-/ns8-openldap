*** Settings ***
Resource        keywords.resource

Suite Setup     Add test users
Suite Teardown  Remove test users

*** Keywords ***
Add test users
    Run task    module/${MID1}/add-user    {"user":"u1","groups":[],"display_name":"User One"}
    Run task    module/${MID1}/add-user    {"user":"u2","groups":[],"display_name":"User Two"}

Remove test users
    Run task    module/${MID1}/remove-user    {"user":"u1"}
    Run task    module/${MID1}/remove-user    {"user":"u2"}

*** Test Cases ***
Add group group1
    Run task    module/${MID1}/add-group    {"group":"group1","description":"First group","users":["u1"]}

    ${out}  ${err}  ${rc} =    Execute Command    podman exec ldapclient ldapsearch -LLL -H ${SURL} -x -D 'uid\=${admuser},ou=People,${DOMSUFFIX}' -w '${admpass}' -b '${DOMSUFFIX}' cn=group1
    ...    return_stderr=${TRUE}    return_rc=${TRUE}
    Should Be Equal As Integers     ${rc}    0
    Should Contain      ${out}      group1
    Should Contain      ${out}      First group
    Should Contain      ${out}      memberUid: u1
    Should Not Contain  ${out}      memberUid: u2

Group already exists
    Run task    module/${MID1}/add-group    {"group":"group1","description":"First group","users":["u1"]}
    ...    rc_expected=2

Alter group group1
    Run task    module/${MID1}/alter-group    {"group":"group1","description":"chdesc","users":["u2"]}

    ${out}  ${err}  ${rc} =    Execute Command    podman exec ldapclient ldapsearch -LLL -H ${SURL} -x -D 'uid\=${admuser},ou=People,${DOMSUFFIX}' -w '${admpass}' -b '${DOMSUFFIX}' cn=group1
    ...    return_stderr=${TRUE}    return_rc=${TRUE}
    Should Be Equal As Integers   ${rc}    0
    Should Contain      ${out}    group1
    Should Not Contain  ${out}    First group
    Should Not Contain  ${out}    memberUid: u1
    Should Contain      ${out}    memberUid: u2
    Should Contain      ${out}    chdesc

Remove group1 description
    Run task    module/${MID1}/alter-group    {"group":"group1","description":""}

    ${out}  ${err}  ${rc} =    Execute Command    podman exec ldapclient ldapsearch -LLL -H ${SURL} -x -D 'uid\=${admuser},ou=People,${DOMSUFFIX}' -w '${admpass}' -b '${DOMSUFFIX}' cn=group1
    ...    return_stderr=${TRUE}    return_rc=${TRUE}
    Should Be Equal As Integers     ${rc}    0
    Should Not Contain    ${out}    description:

Alter non-existing group
    Run task    module/${MID1}/alter-group    {"group":"bad-user","description":"Does not matter","users":[]}
    ...    rc_expected=1

Remove group group1
    Run task    module/${MID1}/remove-group    {"group":"group1"}

    ${out}  ${err}  ${rc} =    Execute Command    podman exec ldapclient ldapsearch -LLL -H ${SURL} -x -D 'uid\=${admuser},ou=People,${DOMSUFFIX}' -w '${admpass}' -b '${DOMSUFFIX}' cn=group1
    ...    return_stderr=${TRUE}    return_rc=${TRUE}
    Should Not Contain    ${out}    numEntries: