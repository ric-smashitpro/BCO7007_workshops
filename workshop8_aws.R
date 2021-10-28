# to record your credentials for AWS access to API
usethis::edit_r_environ()

# documentation
# https://docs.aws.amazon.com/rekognition/index.html

# packages
# install.packages("paws")

library(tidyverse)
library(paws)


#-----------
# Setup

# Create S3 client
s3 <- s3()
# Let us check if there is a S3 bucket we courld use
buckets <- s3$list_buckets()
length(buckets$Buckets)

# create a bucket to store images
s3$create_bucket(Bucket = "ric-smashitpro-rekognition-bucket",
                 CreateBucketConfiguration = list(
                   LocationConstraint = "ap-southeast-2"))
# $Location "http://ric-smashitpro-rekognition-bucket.s3.amazonaws.com/"

buckets <- s3$list_buckets()
buckets <- map_df(buckets[[1]], 
                  ~tibble(name = .$Name, creationDate = .$CreationDate))
buckets

# name                              creationDate       
# <chr>                             <dttm>             
# ric-smashitpro-rekognition-bucket 2021-10-28 00:34:23

# store the name of our created bucket in a separate variable
my_bucket <- buckets$name[buckets$name == "ric-smashitpro-rekognition-bucket"]

#-----------
# Text detection

# check if our test image now really resides in our bucket
bucket_objects <- s3$list_objects(my_bucket) %>% 
  .[["Contents"]] %>% 
  map_chr("Key")

bucket_objects

# Create a Rekognition client
rekognition <- rekognition()

# Referencing an image in an Amazon S3 bucket
resp <- rekognition$detect_text(
  Image = list(
    S3Object = list(
      Bucket = my_bucket,
      Name = bucket_objects
    )
  )
)

# Parsing the response
resp %>% 
  .[["TextDetections"]] %>% 
  keep(~.[["Type"]] == "WORD") %>% 
  map_chr("DetectedText")


#-------
# Facial comparison

# Load raw images into memory
thief <- read_file_raw("thief.jpeg")
suspects <- read_file_raw("usual_suspects.png")

# Send images to the compare faces endpoint
resp <- rekognition$compare_faces(
  SourceImage = list(
    Bytes = thief
  ),
  TargetImage = list(
    Bytes = suspects
  )
)

length(resp$UnmatchedFaces)
length(resp$FaceMatches)

resp$FaceMatches[[1]]$Similarity

# The response of Rekognition's compare faces endpoint
# also includes bounding box coordinates for items that are detected in images
# https://docs.aws.amazon.com/rekognition/latest/dg/images-displaying-bounding-boxes.html

# use the magick package to add the bounding box of the person
# who Rekognition identified as the thief to the image of the suspects.

# install.packages("magick")
library(magick)

# Convert raw image into a magick object
suspects <- image_read(suspects)

# Extract face match from the response
match <- resp$FaceMatches[[1]]

# Calculate bounding box properties
width <- match$Face$BoundingBox$Width * image_info(suspects)$width 
height <- match$Face$BoundingBox$Height * image_info(suspects)$height
left <- match$Face$BoundingBox$Left * image_info(suspects)$width 
top <- match$Face$BoundingBox$Top * image_info(suspects)$height

# Add bounding box to suspects image
image <- suspects %>% 
  image_draw()
rect(left, top, left + width, top + height, border = "red", lty = "dashed", lwd = 5)
image
