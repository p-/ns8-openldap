*** Settings ***
Resource    keywords.resource
Suite Setup    Add another module
Suite Teardown    Remove the additional module

*** Variables ***
${MID1}    na
${DOMAIN}    na

*** Test Cases ***
Join domain
    ${out}    ${err}     ${rc} =    Execute Command
    ...    api-cli run module/${MID2}/configure-module --data '{"provision":"join-domain","domain":"${DOMAIN}","admuser":"${admuser}","admpass":"${admpass}"}'
    ...    return_rc=True  return_stdout=True  return_stderr=True
    Should Be Equal As Integers    ${rc}  0
    ${val} =     Get server url    ${MID2}
    Set Suite Variable    ${surl}    ${val}
    RootDSE is correct    ${surl}

Changes are propagated to them
    [Tags]    unstable
    Fail    Not implemented

Changes are propagated to us
    [Tags]    unstable
    Fail    Not implemented

Leave domain
    ${out}    ${err}     ${rc} =    Execute Command
    ...    api-cli run module/${MID2}/leave-domain
    ...    return_rc=True  return_stdout=True  return_stderr=True
    Should Be Equal As Integers    ${rc}  0



*** Keywords ***
Add another module
    ${module_id} =    Create a module instance
    Set Suite Variable    ${MID2}    ${module_id}

Remove the additional module
    Remove a module instance    ${MID2}