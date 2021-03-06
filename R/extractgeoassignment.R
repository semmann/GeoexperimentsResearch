# Copyright 2016 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#' Extracts a GeoAssignment object.
#'
#' @param obj an object.
#' @param ... further arguments passed on to methods.
#' @return A GeoAssignment object. Or \code{NULL} if not available.
#'
#' @rdname ExtractGeoAssignment

ExtractGeoAssignment <- function(obj, ...) {
  UseMethod("ExtractGeoAssignment")
}

#' Attempts to extract a GeoAssignment object from a GeoTimeseries.
#'
#' @param strict (flag) if FALSE, the function returns NULL if the column
#'   'geo.group' does not exist. Otherwise, throws an error.
#'
#' @return A GeoAssignment object.
#'
#' @note
#' Finds all unique pairs of ('geo', 'geo.group') in the GeoTimeseries.
#' 'geo.group' can have missing values.
#'
#' @rdname ExtractGeoAssignment
ExtractGeoAssignment.GeoTimeseries <- function(obj, strict=TRUE, ...) {
  SetMessageContextString("ExtractGeoAssignment.GeoTimeseries")
  on.exit(SetMessageContextString())

  assert_that(is.flag(strict))
  if (!strict && !(kGeoGroup %in% names(obj))) {
    return(NULL)
  }
  # Ensure that all required columns are in the given data frame.
  CheckForMissingColumns(kGeoGroup, dataframe=obj, what="required")
  # Aggregate all metrics by geo and geo group; keep them in the
  # data frame for reference. By default sort by the 1st metric.
  metrics <- GetInfo(obj, "metrics")
  keys <- c(kGeo, kGeoGroup)
  df.agg <- as.data.frame(unique(obj[keys]))
  df.agg <- df.agg[order(df.agg[[kGeo]]), , drop=FALSE]
  obj.ga <- GeoAssignment(df.agg)
  return(obj.ga)
}

#' @rdname ExtractGeoAssignment
ExtractGeoAssignment.GeoExperimentData <- function(obj, ...) {
  geo.assignment <- GetInfo(obj, "geo.assignment")
  return(geo.assignment)
}
