# Domain name Schema

```txt
http://schema.nethserver.org/openldap/configure-module-input.json#/properties/domain
```



| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                   |
| :------------------ | :--------- | :------------- | :---------------------- | :---------------- | :-------------------- | :------------------ | :------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [configure-module-input.json\*](openldap/configure-module-input.json "open original schema") |

## domain Type

`string` ([Domain name](configure-module-input-properties-domain-name.md))

## domain Constraints

**maximum length**: the maximum number of characters for this string is: `140`

**minimum length**: the minimum number of characters for this string is: `1`

**pattern**: the string must match the following regular expression:&#x20;

```regexp
^[a-zA-Z][-a-zA-Z0-9]{0,62}(\.[a-zA-Z][-a-zA-Z0-9]{0,62})+$
```

[try pattern](https://regexr.com/?expression=%5E%5Ba-zA-Z%5D%5B-a-zA-Z0-9%5D%7B0%2C62%7D\(%5C.%5Ba-zA-Z%5D%5B-a-zA-Z0-9%5D%7B0%2C62%7D\)%2B%24 "try regular expression with regexr.com")
