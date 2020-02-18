#Install packages
library(rayshader) #3D plotting.
library(geoviz) #Elevation data downloader.
library(av) #For making videos (only needed if you want to make things like rotating GIFs).

#Set up the region
lat <- 40.766632 #Lat and long for Living Room Trail, SLC.
long <- -111.811704
square_km <- 0.8 #Size of surrounding area you want to visualize.

#Choose the plotting resolution
max_tiles <- 20 #More tiles results in a higher resolution (but slower to generate) image.

#Get elevation data
dem <- mapzen_dem(lat, long, square_km, max_tiles = max_tiles)

elmat = matrix(
  raster::extract(dem, raster::extent(dem), method = 'bilinear'),
  nrow = ncol(dem),
  ncol = nrow(dem)
)

#Add a satellite image overlay
mapbox_key <- "pk.eyJ1IjoicGF0cmlja2RlYiIsImEiOiJjazVtcmltcWIxMnJmM21wbDZkcHlzMzEwIn0.sAIvHarJXAc6VHgomtK2yQ"

overlay_image <-
  slippy_overlay(
    dem,
    image_source = "mapbox",
    image_type = "satellite",
    png_opacity = 0.6,
    api_key = mapbox_key
  )

#Render the Rayshader scene
elmat %>%
  sphere_shade(texture = "desert") %>%
  add_water(detect_water(elmat), color = "imhof4") %>%
  add_shadow(ray_shade(elmat, zscale = 3), 0.5) %>%
  add_shadow(ambient_shade(elmat), 0) %>%
  add_overlay(overlay_image) %>%
  plot_3d(elmat, zscale = raster_zscale(dem), fov = 0, theta = 0, zoom = 0.75, phi = 55, windowsize = c(1000, 800))
Sys.sleep(0.2)

render_movie('SLC_Living_Room_Trail')