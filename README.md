# signos

## **Feature requirements**

- Screen to view all of the user’s addresses (**Optional:** can filter by the location types mentioned above)
- User can "remove" addresses by swiping
- Users can add a new address by typing in the address or a name of a business in a search bar and the app should present matching results in a tableview.
- Cells are initially collapsed, showing only the full address
- Users can choose a result and the cell will expand to layout:
  - Details of that address
  - A picture of the place if available, (**Optional**: otherwise the position on the map)
  - An “Add” button that would add the address to their address list
  - Phone number (if available for businesses) (**Optional**: and ability to call this business)
  - Ability to see whether the business is a Gym, Restaurant or Supermarket

## **Rules**

1. Written in Swift - Compatible on iPhone (**Optional:** iPad)

2. Please **do not use** any third party libraries (I did not say no services, just no libraries) only use straight apple frameworks

3. Upload to GitHub when done and send back the link to **careers@preziba.com**

4. Time limit: **2 days**

## **Development Submission Status**

- I'm at about 10 hours (and the 24 hour time limit) and the requirements are not complete.
- What is there and working:
  - Screen to view all of the user’s addresses 
  - User can "remove" addresses by swiping
  - Users can add a new address by typing in the address or a name of a business in a search bar and the app should present matching results in a tableview.
  - Users can choose a result and the cell will expand to layout
  - Details of that address, including name and map
  - Add button that saves the address
  - Ability to see if the business is a Gym, Restaurant or Supermarket
- What is not there:
  - You cannot filter adddresses by location type
  - I did not integrate the photos at all. There are reference ids in there that I am assuming that provide another means to access. I would have loaded those in the background and updated an imageview when downloading was complete.
  - I did not integrate the phone number. That would have just been a second call to the "Place Details" endpoint and update only if the user expanded the cell.
  - The default test stubs are there but I did not put any tests in place.
- (Slight cheat?) While I did not use any third-party libraries, I did use an online service to take the JSON results from the Places API and convert it into a Codable compliant struct. 
- Definitely not robustly tested and the API could use some timeouts and internet connection tests. This is very much an MVP.
