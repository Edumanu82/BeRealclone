Project 4 – Instaparse

Submitted by: Eduardo M. Sanchez-Pereyra

Instaparse is a social media photo-sharing app that allows users to upload images using the camera or photo library, attach time and location metadata, view posts within the last 24 hours, and comment on posts. Users cannot view other users’ posts until they upload their own.

Time spent: ~12–15 hours spent in total

Required Features

The following required functionality is completed:

 Users are able to use the back camera to take a photo and upload it to the server OR upload a unique photo from the photo album.

 Posts have a comment section, which displays the commenter’s username and comment text under each post.

 Posts have a time and location attached to them:

Time is displayed using relative formatting (e.g., “2h ago”).

Location is captured using CoreLocation and displayed as City, State using reverse geocoding.

 Photo metadata is extracted from the image (EXIF data such as image dimensions, camera make/model, etc.) and stored in the database.

 Users are not able to see other users’ photos until they upload their own:

Posts are blurred unless they fall within 24 hours of the user’s last post.

 Fetch the 10 most recent photos within the last 24 hours from the server.

 Only show the post if the createdAt property is within 24 hours of the logged-in user’s last post.

Implemented using time interval comparison logic.

 UIVisualEffectView is used to blur restricted posts.

Optional Features

The following optional features are implemented:

 Reverse geocoding converts latitude/longitude into City and State.

 Relative time display using RelativeDateTimeFormatter.

 Comment section directly embedded under each post.

 Metadata fields saved to Parse database.

 Pull-to-refresh functionality on feed.

Additional Features

Comment section embedded directly within each post cell.

Caching for reverse geocoded locations to improve performance.

Automatic feed refresh after a new post is uploaded.

Metadata storage including image width, height, camera model, and original photo date.

Clean UI layout using stack views.

Video Walkthrough

Here’s a walkthrough of implemented user stories:

👉 (Insert Loom or YouTube link here)

Notes

Challenges encountered:

Handling ParseSwift model conformance issues (ParseObject protocol requirements).

Managing CoreLocation permissions correctly on both simulator and physical devices.

Implementing reverse geocoding while avoiding excessive geocoder calls.

Preventing table view cell reuse from overwriting comment and location data.

Handling asynchronous comment queries inside reusable table view cells.

Ensuring proper pointer inclusion when querying User objects.

License

Copyright 2026 Eduardo M. Sanchez-Pereyra

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

If you’d like, I can also:

Shorten it to exactly match your rubric wording

Make it more “professional sounding”

Or help you write the “Video Walkthrough” description section for maximum clarity 👌

no fill in with what i have done 

Got it 👍 I’ll fill it in based only on what you’ve actually implemented in your Instaparse project (camera/photo upload, time, location, blur rule, comments under caption, metadata, etc.).

Here’s your completed README:

Project 4 – Instaparse

Submitted by: Eduardo M. Sanchez-Pereyra

Instaparse is a social media photo-sharing app that allows users to upload photos using the camera or photo library, attach time and location to posts, view posts from the last 24 hours, and comment directly under each post. Users must upload a post before viewing other users’ posts.

Time spent: ~14 hours spent in total

Required Features

The following required functionality is completed:

 Users are able to use the back camera to take a photo and upload it to the server OR upload a unique photo from the photo album.

 Posts have a comment section, which displays commenter’s username and comment context.

 Posts have a time and location attached to them.

 Get Photo Metadata (EXIF metadata extracted and stored with post).

 Users are not able to see other users’ photos until they upload their own.

 Fetch the 10 most recent photos within the last 24 hours from the server.

 Only show the post if the createdAt property is within 24 hours of the logged in user’s last post.

 Posts outside the 24-hour visibility window are blurred using UIVisualEffectView.

Optional Features

The following optional features are implemented:

 Reverse geocoding to convert latitude/longitude into City and State.

 Relative time display (e.g., “2h ago”).

 Pull-to-refresh functionality on feed.



Additional Features

Metadata extraction including image width, height, camera make/model, and original photo timestamp.

Location caching for improved performance.

Automatic feed refresh after a new post is uploaded.

Clean UI layout using stack views and auto layout constraints.

Video Walkthrough

Here’s a walkthrough of implemented user stories:

https://www.loom.com/share/2c60dca16cf94759abb733cba9d5db31

Notes

Challenges encountered while building the app:

Fixing ParseSwift ParseObject conformance issues.

Managing CoreLocation permissions on physical device.

Implementing reverse geocoding and avoiding excessive geocoder calls.

Handling asynchronous comment queries inside reusable table view cells.

Ensuring correct pointer inclusion when querying _User objects.

Preventing reused cells from displaying incorrect comment/location data.

License

Copyright 2026 Eduardo M. Sanchez-Pereyra

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
