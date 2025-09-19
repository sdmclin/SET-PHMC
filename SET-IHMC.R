################################################################################
# ET-PHMC: Spatial Exploration Tool for Isochrone Modelling                    #
#          of Past Human Mobility Catchments                                   #
# Site: Point of Interest (POI)                                               #
# Purpose: Compute isochrone (time-cost area reachable on foot)                #
#          using Tobler's hiking function with optional slope damping          #
################################################################################

################################################################################
# PART 1 - Load libraries and DEM/slope                                        #
################################################################################

# Load necessary libraries
library(raster)     # raster data manipulation and visualization
library(sp)         # handling spatial data
library(sf)         # handling simple features and modern spatial data
library(gdistance)  # creating TransitionLayer and calculating accumulated cost 

# Load DEM (digital elevation model) and slope raster (degrees)
# of the Point of Interest (POI)
# Rasters should be in the same resolution, extent, and projection
POI_dem   <- raster("PATH/TO/POI_dem.tif")
POI_slope <- raster("PATH/TO/POI_slope.tif")

################################################################################
# PART 2 - Define starting location (the cave site)                            #
################################################################################

# Coordinates of POI (lon, lat in WGS84)
xCoord <- xx.xxxx
yCoord <- xx.xxxx

# Convert coordinates into spatial point in DEM’s CRS
coordinates_POI <- SpatialPoints(cbind(xCoord, yCoord),
                                 proj4string = CRS("+proj=longlat +datum=WGS84"))
coordinates_POI <- spTransform(coordinates_POI, CRS(projection(POI_dem)))

################################################################################
# PART 3 - Adjust Movement Parameters                                          #
################################################################################

# Apply damping if slope exceeds a threshold (in degrees)
damping <- TRUE
dampingFactor = 16  # threshold slope in degrees

# Number of directions for movement (4 = rook, 8 = queen, 16 = knight)
numberOfDirections <- 8

# Parameters: time horizon and walking speed
timeOfInterest <- 2.15       # isochrone cutoff in hours
WlkSpeed <- 1.27 * 3.6       # baseline walking speed in km/h

# Define Tobler’s hiking function (adjusted)
# Input: slope in degrees → Output: walking speed in km/h
ToblersHikingFunctionAdjusted <- function(x) {
  6 * exp(-3.5 * abs(tan(x * pi / 180) + 0.05))
}

################################################################################
# PART 4 - Build velocity raster                                               #
################################################################################

# Apply Tobler’s function on slope raster
# This function takes the slope raster and applies Tobler's Hiking Function
# to calculate the hiking velocity in km/h for each cell based on its slope
vel <- calc(POI_slope, fun = ToblersHikingFunctionAdjusted)

# Rescale velocity so that 0° slope corresponds to WlkSpeed
vel <- vel * (WlkSpeed / ToblersHikingFunctionAdjusted(0))

# Convert to m/s for cost calculations
vel <- vel * (1000 / 3600)

# Apply damping penalty above threshold slope
# This adjustment is to exaggerate the difficulty of moving through steeper slopes
if (damping) {
  penalty <- POI_slope
  penalty[penalty > dampingFactor] <- 1000   # divide v by 1000 if above threshold
  penalty[penalty <= dampingFactor] <- 1
  vel <- vel / penalty
}

################################################################################
# PART 5 - Build transition matrix                                             #
################################################################################

# The transition layer represents the cost of moving from one cell to another,
# calculated as the mean velocity between cells.
# The transitionFunction = mean argument specifies that the transition values
# should be computed using the mean of the adjacent cell values, and
# directions = 8, i.e. all eight possible directions (N, NE, E, SE, S, SW, W, NW)

# Create transition matrix: conductance = mean of neighboring velocities
tr <- transition(vel, transitionFunction = mean, directions = numberOfDirections)

# Correct for geographic distortion (cell size, diagonal distances, etc.)
tr <- geoCorrection(tr, type = "r")

################################################################################
# PART 6 - Accumulated cost surface                                            #
################################################################################

# The accumulated cost surface is calculated from the geocorrected
# transition layer and the starting point, representing the total cost
# (in terms of time or difficulty) of reaching each cell from the starting point
# The accCost function uses the transition layer
# to compute the least-cost paths and accumulated costs

# Calculate accumulated travel cost (in seconds) from cave point
accumulatedCost <- accCost(tr, coordinates_POI)

# Convert to hours
accumulatedCost <- accumulatedCost / 3600

################################################################################
# PART 7 - Extract isochrone contour                                           #
################################################################################

# Extract contour line at the defined time of interest
contour_POI <- rasterToContour(accumulatedCost, levels = timeOfInterest)

# Save contour shapefile
shapefile(contour_POI, filename = "isochrone_POI_2h15min.shp", overwrite = TRUE)

################################################################################
# PART 8 - Export results                                                      #
################################################################################

# Export the accumulated cost raster (hours)
writeRaster(accumulatedCost, filename = "accumulatedCost_POI.asc",
            format = "ascii", overwrite = TRUE)

# Plot quick visualization
plot(accumulatedCost, main = "Accumulated travel time (hours) - POI")
plot(contour_POI, add = TRUE, col = "red", lwd = 2)
points(coordinates_POI, col = "blue", pch = 19)
