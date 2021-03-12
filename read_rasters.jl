# test reading spatial data

# load packages
using ArchGDAL
const AG = ArchGDAL

# load ele data as a test
dataset = AG.readraster("../elemove/data/kruger_temp_200m.tif")

# get drivers
dataset => [AG.width, AG.height]
