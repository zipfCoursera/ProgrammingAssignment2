
# The two functions below work together to provide a cache functionality for the 
# inverse matrix calculation.

# makeCacheMatrix() gets a matrix and returns a list object containing a set of functions to get and 
# set a matrix, and get and set the inverse matrix.
# The object created by this function is the input of cacheSolve(), which determines if the inverse
# of the underlying matrix already exists. If it exists, it returns that. If not, it generates the 
# inverse matrix, and stores its value in the object generated by makeCacheMatrix() using
# the <<- operator, which searches the definition of variable my_inv through parent environments, 
# redefining its value.


# I have included in the same repository a supplementary RMarkdown report (CacheMatrixInAction.md) 
# with some usage examples. It also shows how to improve function cacheSolve() with a matrix singularity 
# check using function is.singular.matrix from package matrixcalc.



makeCacheMatrix <- function(x = matrix()) {
  
  my_inv <- NULL                            # Initializes the inverse matrix variable 
  
  set <- function(y) {      
    x <<- y                                 # Changes the value of x
    my_inv <<- NULL                         # Resets my_inv
  }
  
  get<-function() x                         # Returns the value of x
  
  setinv <- function(inv) my_inv <<- inv    # Sets my_inv to inv
  
  getinv <- function() my_inv               # Returns the inverse matrix (my_inv)
  
  list(
    set = set, 
    get = get,
    setinv = setinv, 
    getinv = getinv
  )
  
}



cacheSolve <- function(x, ...) {
  
  # Return a matrix that is the inverse of 'x'
  
  my_inv <- x$getinv()
  
  if(!is.null(my_inv))
  {
    message("Returning inverse matrix available in the cache...")
    return(my_inv)
  }
  
  matrix <- x$get()
  
  my_inv <- solve(matrix, ...)
  
  x$setinv(my_inv)
  
  my_inv
  
}
