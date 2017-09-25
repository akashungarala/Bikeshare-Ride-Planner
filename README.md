# Bikeshare-Ride-Planner
**Bikeshare Ride Planner** is an iOS app for bikeshare users to determine if bikeshare is a good option for a particular trip. The app enables users to find available bikeshare stations within a specified distance of the rider’s origin and destination.

## Platform

iOS 10, Swift 3, XCode 8

## Functionalities

- [x] Download the Bay Area Bikeshare station feed at the following url: http://www.bayareabikeshare.com/stations/json
- [x] Display a map (e.g. Apple Maps)
      
      - The map should be dynamic and interactive (e.g. zoom, pan, tap, etc.)
      - Prior to any search, the map should
        - be somewhat centered on the user's current location
        - display all bikeshare stations within the visible bounding box
- [x] Display origin and destination input text fields
- [x] Display an element (e.g. slider, picker, etc.) to allow the user to set a desired walking distance to stops nearest the origin and destination e.g. 0.5 miles from origin/destination to bus stop

      - The distance measurement units should be miles.
      - The distance selection range should be between 0 and 2 miles.
      - Set the default distance value to 0.25 miles.
- [x] Allow the user to input their origin and destination, and then confirm they are valid locations
      
      - Allow current location as an input option for origin
      - Applying an autocomplete feature to this input is a bonus
- [x] Once the user confirms his/her origin/destination inputs, hide all map markers first. Then display a unique marker at the origin and at the destination. Display different markers for the bikeshare stations located within the specified distance at both origin and destination.
      
      - Bikeshare stations that have bikes available within the specified distance of the origin should be marked green
      - Empty bikeshare stations within the specified distance of the origin should be marked red
      - Bikeshare stations that have docks available within the specified distance of the destination should be marked green
      - Full bikeshare stations within the specified distance of the destination should be marked red
      - Displaying a generated route between the origin and destination markers is a bonus
- [x] If the user clicks any of the bikeshare station markers, a popup should display the street address and a “Directions to …” link to an Apple Maps walking directions
      
      - For station markers near the origin, the popup should have a “Directions to here” link, and the Apple Maps walking directions should be from the origin to the selected bikeshare station
      - For station markers near the destination, the popup should have a “Directions from here” link, and the Apple Maps walking directions should be from the selected bikeshare station to the destination
      
## Screenshots

Here's a walkthrough of the app functionalities:

**Launch Screen**

![1 - launch screen](https://user-images.githubusercontent.com/7720015/30827372-8ab1f8fe-a1ff-11e7-9f39-3ce79626fd03.PNG)


**Home Screen**

![2 - home screen](https://user-images.githubusercontent.com/7720015/30827373-8ab3f1cc-a1ff-11e7-9fa9-826cdf476444.PNG)

**Bikeshare Station**

![3 - bikeshare station](https://user-images.githubusercontent.com/7720015/30827375-8ab8bf68-a1ff-11e7-8510-d03d4a6e0d60.PNG)

**Directions to Bikeshare Station**

![4 - directions to bikeshare station](https://user-images.githubusercontent.com/7720015/30827377-8ab985d8-a1ff-11e7-86ab-9eed6170aedf.PNG)

**Origin Search**

![5 - origin search](https://user-images.githubusercontent.com/7720015/30827374-8ab7be92-a1ff-11e7-85ff-043b699c9adf.PNG)

**Destination Search**

![6 - destination search](https://user-images.githubusercontent.com/7720015/30827376-8ab9804c-a1ff-11e7-8dea-c0af332a7046.PNG)

**Bikeshare Station Near Origin**

![7 - bikeshare station near origin](https://user-images.githubusercontent.com/7720015/30827379-8add0dfa-a1ff-11e7-9ee5-ed73a4f8db83.PNG)

**Directions from Origin to Bikeshare Station**

![8 - directions from origin to bikeshare station](https://user-images.githubusercontent.com/7720015/30827381-8af1d5c8-a1ff-11e7-8ca7-8647bc16eb56.PNG)

**Bikeshare Station Near Destination**

![9 - bikeshare station near destination](https://user-images.githubusercontent.com/7720015/30827378-8adc1594-a1ff-11e7-97eb-4248a08ff04d.PNG)

**Directions from Bikeshare Station to Destination**

![10 - directions from bikeshare station to destination](https://user-images.githubusercontent.com/7720015/30827380-8ae1bd00-a1ff-11e7-9d18-e178dca7e1ba.PNG)

## Cloning the Project

Get started by cloning the project to your local machine: https://github.com/akashungarala/Bikeshare-Ride-Planner
