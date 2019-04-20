class AssigneeClass {
  String id;
  String username;
  String firstName;
  String lastName;
  String email;
  String profilePicture;
  String displayName;

  AssigneeClass(this.id, this.username, this.firstName, this.lastName,
      this.email, this.profilePicture, this.displayName);

  @override
  String toString() {
    return 'assignee{id: $id, username: $username, first_name: $firstName, last_name: $lastName, email: $email, profile_picture: $profilePicture}';
  }
}
