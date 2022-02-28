enum Role{
  user,
  admin,
}

class OrobixUser{
  final String name;
  final String surname;
  final String email;
  final String uuid;
  Role role = Role.user;

  OrobixUser(this.email, this.name, this.surname, this.uuid);
  
}