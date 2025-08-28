enum FollowStatus {
  self,       // khud ka profile
  following,  // already following
  pending,    // request sent but not accepted
  none,       // not following
}

FollowStatus followStatusFromString(String s) {
  switch (s) {
    case "self":
      return FollowStatus.self;
    case "following":
      return FollowStatus.following;
    case "pending":
      return FollowStatus.pending;
    default:
      return FollowStatus.none;
  }
}
