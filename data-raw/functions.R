# Cole Tanigawa-Lau
# Mon Nov 27 16:20:03 2017
# Description: Functions for gathering and cleaning congressional apportionment data.

save_list <-
  function(x, dir, ext = ".rds", names = NULL,
           cores = 1, ...){
    if(!file.exists(dir)) dir.create(dir)

    if(is.null(names)) names <- names(x) else names(x) <- names
    require(parallel)

    dir2 <- ifelse(grepl(dir, patt = "/$"), dir, paste0(dir, "/"))

    if(grepl(ext, patt = "\\.?rds$", ignore.case = TRUE)){
      mclapply(names, function(i) saveRDS(x[[i]],
                                          paste0(dir2, i, ext),
                                          ...),
               mc.cores = cores
      )
    }

    if(grepl(ext, patt = "\\.?csv$", ignore.case = TRUE)){
      if(require(data.table)){
        mclapply(names, function(i) fwrite(x[[i]],
                                           file = paste0(dir2, i, ext),
                                           ...),
                 mc.cores = cores
        )
      }else{
        mclapply(names, function(i) write.csv(x[[i]],
                                              file = paste0(dir2, i, ext),
                                              ...),
                 mc.cores = cores
        )
      }
    }

    if(grepl(ext, patt = "\\.?shp$", ignore.case = TRUE)){
      if(require(maptools)){
        mclapply(names, function(i) writeSpatialShape(x[[i]],
                                                      paste0(dir2, i, ext),
                                                      ...),
                 mc.cores = cores
        )
      }else{ stop("Package 'maptools' must be installed to save spatial objects") }
    }
  }
