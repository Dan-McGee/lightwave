REL_DIR=`dirname $0`
cd $REL_DIR

source ../header.sh

echo "##################################################################################"
echo "ACL TEST ON ADD as 'ADMIN': Add new entry under ou=eng,dc=vmware,dc=com as 'admin'"
echo "##################################################################################"
echo

ldapadd -c -h $host -p $port -x -D "cn=admin,cn=users,dc=vmware,dc=com" -w 123 <<EOM
dn: cn=John-add,ou=eng,dc=vmware,dc=com
changetype: add
cn: John-add
sn: Smith
objectClass: person
objectClass: organizationalPerson
telephoneNumber: 425-123-456-91
facsimileTelephoneNumber: 425-456-123-91
street: 20517 NE 91 th street
st: washington
l: redmond
postalCode: 98052
ou: Engineering
title: engineer
description: Employee of VMware
EOM

ldapsearch -h $host -p $port -x -D "cn=Admin,cn=Users,dc=vmware,dc=com" -w 123 -b "dc=com" -s subtree "(cn=john-add)" dn

echo "#####################################################################################"
echo "ACL TEST ON DELETE as 'ADMIN': Delete entry under ou=eng,dc=vmware,dc=com as 'admin'"
echo "#####################################################################################"
echo
ldapadd -c -h $host -p $port -x -D "cn=admin,cn=users,dc=vmware,dc=com" -w 123 <<EOM
dn: cn=John-add,ou=eng,dc=vmware,dc=com
changetype: delete
EOM

ldapsearch -h $host -p $port -x -D "cn=Admin,cn=Users,dc=vmware,dc=com" -w 123 -b "dc=com" -s subtree "(cn=john-add)" dn

echo "Add the entry back to do DELETE test"
echo

ldapadd -c -h $host -p $port -x -D "cn=admin,cn=users,dc=vmware,dc=com" -w 123 <<EOM
dn: cn=John-add,ou=eng,dc=vmware,dc=com
changetype: add
cn: John-add
sn: Smith
objectClass: person
objectClass: organizationalPerson
telephoneNumber: 425-123-456-91
facsimileTelephoneNumber: 425-456-123-91
street: 20517 NE 91 th street
st: washington
l: redmond
postalCode: 98052
ou: Engineering
title: engineer
description: Employee of VMware
EOM

ldapsearch -h $host -p $port -x -D "cn=Admin,cn=Users,dc=vmware,dc=com" -w 123 -b "dc=com" -s subtree "(cn=john-add)" dn

echo "#####################################################################################"
echo "ACL TEST ON DELETE as 'John-1': Delete entry under ou=eng,dc=vmware,dc=com as 'John-1'"
echo "#####################################################################################"
echo
ldapadd -c -h $host -p $port -x -D "cn=John-1,ou=eng,dc=vmware,dc=com" -w "PaWorD@123" <<EOM
dn: cn=John-add,ou=eng,dc=vmware,dc=com
changetype: delete
EOM

ldapsearch -h $host -p $port -x -D "cn=Admin,cn=Users,dc=vmware,dc=com" -w 123 -b "dc=com" -s subtree "(cn=john-add)" dn

echo "#####################################################################################"
echo "ACL TEST ON DELETE as 'Admin': Delete entry under ou=eng,dc=vmware,dc=com as 'Admin'"
echo "#####################################################################################"
echo
ldapadd -c -h $host -p $port -x -D "cn=Admin,cn=users,dc=vmware,dc=com" -w 123 <<EOM
dn: cn=John-add,ou=eng,dc=vmware,dc=com
changetype: delete
EOM

echo "###################################################################################"
echo "ACL TEST ON ADD as 'John-1': Add new entry under ou=eng,dc=vmware,dc=com as 'John-1'"
echo "###################################################################################"
echo

ldapadd -c -h $host -p $port -x -D "cn=John-1,ou=eng,dc=vmware,dc=com" -w "PaWorD@123" <<EOM
dn: cn=John-add,ou=eng,dc=vmware,dc=com
changetype: add
cn: John-add
sn: Smith
objectClass: person
objectClass: organizationalPerson
telephoneNumber: 425-123-456-91
facsimileTelephoneNumber: 425-456-123-91
street: 20517 NE 91 th street
st: washington
l: redmond
postalCode: 98052
ou: Engineering
title: engineer
description: Employee of VMware
EOM


echo "###########################################################################"
echo "ACL TEST ON SYSTEM ENTRIES: Create telephonenumber equality index as 'admin'"
echo "###########################################################################"
echo

ldapmodify -c -h $host -p $port -x -D "cn=Admin,cn=Users,dc=vmware,dc=com" -w 123 <<EOM
dn: cn=indices,cn=config
changetype: modify
add: vmwAttrIndexDesc
vmwAttrIndexDesc: telexNumber eq
EOM


echo "###########################################################################"
echo "ACL TEST ON SYSTEM ENTRIES: Create telephonenumber equality index as 'John-1'"
echo "###########################################################################"
echo
ldapmodify -c -h $host -p $port -x -D "cn=John-1,ou=eng,dc=vmware,dc=com" -w "PaWorD@123" <<EOM
dn: cn=indices,cn=config
changetype: modify
add: vmwAttrIndexDesc
vmwAttrIndexDesc: telexNumber eq
EOM


ldapsearch -h $host -p $port -x -D "cn=Admin,cn=Users,dc=vmware,dc=com" -w 123 -b "cn=indices,cn=config" -s base "objectclass=*" vmwAttrIndexDesc

echo "######################################################################"
echo "Add an attribute value (displayName: david) to an existing indexed attribute."
echo "######################################################################"
echo

echo "Bind as admin to modify John-2"
ldapmodify -c -h $host -p $port -x -D "cn=Admin,cn=Users,dc=vmware,dc=com" -w 123 <<EOM
dn: cn=John-2,ou=eng,dc=vmware,dc=com
changetype: modify
add: displayName
displayName: wfu
EOM

ldapsearch -h $host -p $port -x -D "cn=Admin,cn=Users,dc=vmware,dc=com" -w 123 -b "cn=John-2,ou=eng,dc=vmware,dc=com" -s base "objectclass=*" displayName

echo "Bind as John-2 to modify John-2"
ldapmodify -c -h $host -p $port -x -D "cn=John-2,ou=eng,dc=vmware,dc=com" -w "PaWorD@123" <<EOM
dn: cn=John-2,ou=eng,dc=vmware,dc=com
changetype: modify
delete: displayName
EOM

ldapsearch -h $host -p $port -x -D "cn=Admin,cn=Users,dc=vmware,dc=com" -w 123 -b "cn=John-2,ou=eng,dc=vmware,dc=com" -s base "objectclass=*" displayName


echo "Bind as John-1 to modify John-2"
ldapmodify -c -h $host -p $port -x -D "cn=John-1,ou=eng,dc=vmware,dc=com" -w "PaWorD@123" <<EOM
dn: cn=John-2,ou=eng,dc=vmware,dc=com
changetype: modify
add: displayName
displayName: wfu
EOM

echo
echo "Bind Anonymously to search for 'cn=schemacontext'"
echo "Anonymous search on 'cn=schemacontext' subtree should be allowed"
ldapsearch -h $host -p $port -x -b "cn=schemacontext" -s subtree "(objectClass=*)" dn

echo
echo "Bind as John-1 to search for 'cn=schemacontext'"
echo "A normal user should also have access right to 'cn=schemacontext' search"
ldapsearch -h $host -p $port -x -D "cn=John-1,ou=eng,dc=vmware,dc=com" -w "PaWorD@123" -b "cn=schemacontext" -s subtree "(objectClass=*)" dn

echo
echo "Bind as John-1 to search for 'dc=vmware,dc=com'"
echo "A normal user should not have access right to 'dc=vmware,dc=com' (admin/admins have)"
ldapsearch -h $host -p $port -x -D "cn=John-1,ou=eng,dc=vmware,dc=com" -w "PaWorD@123" -b "dc=vmware,dc=com" -s base "(objectClass=*)" dn
