# Updating the test answers

Some of the items on the test change occasionally.  There are two files, where these are stored.

* us.json

<https://uscis.gov/citizenship/testupdates> to update:

* What is the name of the President of the United States now?
* What is the name of the Vice President of the United States now?
* How many justices are on the Supreme Court?
* Who is the Chief Justice of the United States now?
* What is the political party of the President now?
* What is the name of the Speaker of the House of Representatives now?

* states.json

<https://www.usa.gov/states-and-territories> to update:

* Who is one of your state’s U.S. Senators now?
* Name your U.S. Representative.
* Who is the Governor of your state now?
* What is the capital of your state?

The official source of this data is the US Government at these two locations:

* <http://clerk.house.gov/xml/lists/MemberData.xml>
* <http://www.senate.gov/general/contact_information/senators_cfm.xml>

There are three dart programs in the tool directory that will attempt to
automatically download new files and generate JSON files.

Then generate the Dart files from json like so:

```bash
flutter packages pub run build_runner build --verbose --delete-conflicting-outputs
```
