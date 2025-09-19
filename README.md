# SET-PHMC: **S**patial **E**xploration **T**ool for Isochrone Modelling of **P**ast **H**uman **M**obility **C**atchments

This repository contains a R script for modelling past human mobility catchments around caves using **Tobler’s hiking function** and cost-distance analysis. The tool was applied in the context of the [REVIVE Project](https://uni-tuebingen.de/fakultaeten/mathematisch-naturwissenschaftliche-fakultaet/fachbereiche/geowissenschaften/arbeitsgruppen/urgeschichte-naturwissenschaftliche-archaeologie/ina/palaeoanthropologie/research/revive/) and contributed to the study:

> Russo, G., Rivals, F., Duval, M., McLin, S.D., Aljaber Abo Fakher, M., Haïdar-Boustani, M., Martinez-Pillado, V., Hasözbek, A., Garrard, A., Bibi, F., Hilbert, Y.H., el Zaatari, S. (in review).  
> *Hunting strategies and land use reflect ecological knowledge in the Pleistocene woodlands of the Central Levant.*

---

## ✨ Features

- Implements **Tobler’s hiking function** for slope-dependent walking speed 
- Allows optional **slope damping** (>16° penalty)  
- Computes **accumulated time-cost surfaces** from cave sites 
- Extracts **isochrones** (e.g. 2.15 h travel radius)
- Supports scenario comparisons:  
  - *Homo sapiens* vs. Neanderthals (`amh` vs `nean`) 
  - Short vs long walking assumptions (`short` vs `long`, different baseline velocities)  
- Outputs are designed for further analysis in **ArcGIS/QGIS** 

---

## 📂 Repository Structure

```
MobilityCatchR        # Example site
  input/              # DEM, slope, coordinates
  output/             # Isochrone shapefiles & rasters for different scenarios
  SET-PHMC.R          # site-specific script
```

---

## 🔧 Requirements

- **R >= 4.3**
- R packages:  
  `raster`, `sp`, `sf`, `terra`, `gdistance`

---

## 📥 Input Data

- **DEM**: ASTER or derived from [ALOS World 3D](https://portal.opentopography.org/raster?opentopoID=OTALOS.112016.4326.2) (accessed via OpenTopography)  
- **Slope raster**: Computed from DEM using geospatial tools 
- DEMs were clipped to the area of interest and adjusted for paleoshorelines before analysis
- Input coordinate system: **WGS84**; rasters reprojected to **UTM Zone 36N** for area calculations  

*(Due to licensing/size restrictions, DEM and slope rasters are not included here. Users should obtain their own DEMs from the sources above)*

---

## 🚀 Usage

Example for Ras el-Kelb (`SET_rek.R`):

```r
# Run in R
source("SET-PHMC_rek.R")
```

The script will:
1. Load DEM, slope, and site coordinates  
2. Compute accumulated time-cost raster (hours)  
3. Extract 2.15 h isochrone contour 
4. Export:  
   - **Time-cost raster** (`.asc`)  
   - **Isochrone shapefile** (`.shp`, `.dbf`, `.shx`)  

Scenario outputs are stored under:  
`output/amh_short`, `output/amh_long`, `output/nean_short`, `output/nean_long`.

---

## 🗺️ Post-processing in ArcGIS/QGIS

After exporting isochrones from R:
1. Import shapefiles into GIS  
2. Overlay with slope raster  
3. Reclassify slope into **flat (<30°)** vs **mountainous (≥30°)**  
4. Compute **area proportions** within the isochrone

---

## 📊 Outputs

- **Time-cost raster**: travel time from site (hours)  
- **Isochrone shapefile**: contour at 2.15 h threshold  
- **GIS outputs**: area statistics of flat vs mountainous terrain  
- Scenario comparison between *H. sapiens* and Neanderthals  

---

## 📖 Citation & Acknowledgement

This tool is adapted from the framework of:

> Schmidt, K. & Gries, P. M. (2016).  
> *Technical Note 3: Isochrones and Catchment Areas.* Collaborative Research Centre 1070 – ResourceCultures, University of Tübingen.  
> [Link](https://uni-tuebingen.de/en/research/core-research/collaborative-research-centers/sfb-1070/archive/second-funding-phase/organisation/service-project-s/technical-notes/technical-note-3/)
>  
>    > Adaptations in this version include:
  
 - Coordinates provided in WGS84 and transformed to raster CRS
 - Use of DEM + slope rasters prepared externally (no in-script slope derivation)
 - Optional slope damping (16° threshold) to penalize steep terrain
 - Scenario runs for H. sapiens vs. Neanderthals ("amh" vs. "nean") and different walking assumptions ("short" vs. "long")
 - Export of time-cost rasters and isochrone shapefiles for subsequent terrain composition analysis in ArcGIS

Please cite as:  
McLin, S.D. & Russo, G. (2025)  
*SET-PHMC: Spatial Exploration Tool for Isochrone Modelling in the Levant.* GitHub repository.  

---

## 📜 License

This repository is licensed under the **MIT License**.  
See [LICENSE](LICENSE) for details.  

---

## 📬 Contact

Maintainer: **Scott D. McLin**

University of Tübingen
Faculty of Science
Department of Geosciences
📧 scott.mclin@uni-tuebingen.de  
