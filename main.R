# Stefan van Dam
# Janna Jilesen

# 9-1-2015

# Packages
library(sp)
library(rgdal)
library(rgeos)

#Downloading and unzipping data into the data folder
download.file(url = 'http://www.mapcruzin.com/download-shapefile/netherlands-places-shape.zip', destfile = 'data/places.zip', method = 'auto')
unzip(zipfile='data/places.zip', exdir='data/places')
download.file(url = 'http://www.mapcruzin.com/download-shapefile/netherlands-railways-shape.zip', destfile = 'data/railway.zip', method = 'auto')
unzip(zipfile='data/railway.zip', exdir='data/railway')

# Open data files
dsnRailway = file.path("data/Railway","railways.shp")
ogrListLayers(dsnRailway)
railway <- readOGR(dsnRailway, layer = ogrListLayers(dsnRailway))

dsnPlaces = file.path("data/Places","places.shp")
ogrListLayers(dsnPlaces)
places <- readOGR(dsnPlaces, layer = ogrListLayers(dsnPlaces))
plot(railway)

# Selecting railways of type = Industry
RailwayIndus <- railway[railway$type=="industrial",]

# Reprojecting our Data
prj_string_RD <- CRS("+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +towgs84=565.2369,50.0087,465.658,-0.406857330322398,0.350732676542563,-1.8703473836068,4.0812 +units=m +no_defs")
RailwayIndusRD <- spTransform(RailwayIndus, prj_string_RD)
PlacesRD <- spTransform(places, prj_string_RD)

# Making the buffer
RailwayBuffer <- gBuffer(RailwayIndusRD, width=1000, quadsegs=100, byid = TRUE)

# Looking for intersections of Places and Railways
intersectionRP <- gIntersection(PlacesRD, RailwayBuffer, byid = TRUE)
intersectsRP <- gIntersects(PlacesRD, RailwayBuffer, byid = TRUE)

# Getting placename and population of intersected place
placenr <- which(intersectsRP == TRUE)
placename <- PlacesRD$name[placenr]
coordx <- intersectionRP$x[1]
coordy <- intersectionRP$y[1]
pop <- PlacesRD$population[placenr]

# Plotting the buffer of the railway, the places that intersect with it and the names of those places
plot(RailwayBuffer, col="red")
plot(intersectionRP, add=TRUE, col="blue")
mytext <- text(coordx, coordy, labels = placename)

# The city intersecting with the industrial railway is Utrecht. The populationsize is  100,000 people.



