# API schema spec


#### Resources
For the examples we will use a Schema of the following:


`Facebook/Event`
```
Schema Event {
  id: String 'uuid()'
  dateCreated: String 'Date'
  dateRecorded: String 'Date' // date from the source
  name: String ''
  images: Array []
  location: Map Location
  userId: String 'userId'
}

Schema Location {
  ... // id, dateCreated, etc
  lat: Number nil
  lon: Number nil
  name: String '' // location name, Seattle
  images: Array []
}
```

Example data:

```
%Event{
  id: "uuid-ab82",
  name: "Check in at Pikes peak",
  userId: "12",
  location: %{
    id: "uuid-ab83",
    lat: 38.840864,
    lon: -105.042263,
    name: "Pikes peak"
  }
}
```

This example Event item can support both a map location event and a timeline life event.

```
GET /<resource>/locations

[
  {
    id: "uuid-ab83",
    lat: 38.840864,
    lon: -105.042263,
    name: "Pikes peak",
    events: [
      {
        id: "uuid-ab82",
        name: "Check in at Pikes peak",
        userId: "12"
      }
    ]
  }
]
```
