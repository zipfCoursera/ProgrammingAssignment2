# Cache Matrix Functions in Action
Enrique Nell  
27 Mar 2016  

## Function makeCacheMatrix()

This function gets a matrix and returns a list object with a set of functions that provide a cache 
functionality for the inverse matrix calculation.


```r
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
```


## Function cacheSolve()

The input of **cacheSolve()** is the output of **makeCacheMatrix()**. It returns the inverse of the underlying matrix. Before calculating the inverse, it communicates with the input object to check if it has been calculated already, and in that case returns the inverse from the cache.


```r
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
```


Let's see some examples:


```r
matrix1 <- matrix(rnorm(9), nrow=3, ncol=3)  # square matrix
matrix1
```

```
##            [,1]       [,2]       [,3]
## [1,] -0.6277146  0.5725958 -0.4496416
## [2,]  0.8617548 -0.9505873  0.6659199
## [3,]  0.2480548  1.3542575  1.2521187
```

Now let's create our "special" matrix object using **makeCacheMatrix()**:


```r
spec.matrix1 <- makeCacheMatrix(matrix1)

spec.matrix1$get()
```

```
##            [,1]       [,2]       [,3]
## [1,] -0.6277146  0.5725958 -0.4496416
## [2,]  0.8617548 -0.9505873  0.6659199
## [3,]  0.2480548  1.3542575  1.2521187
```

Do we have an inverse matrix yet?

```r
spec.matrix1$getinv()
```

```
## NULL
```

Let's create it using **cacheSolve()**:


```r
cacheSolve(spec.matrix1)
```

```
##            [,1]      [,2]       [,3]
## [1,] -13.141583 -8.328703 -0.2897115
## [2,]  -5.740346 -4.236548  0.1917577
## [3,]   8.812055  6.232118  0.6486406
```

if we now run function **cacheSolve()** again:


```r
cacheSolve(spec.matrix1)
```

```
## Returning inverse matrix available in the cache...
```

```
##            [,1]      [,2]       [,3]
## [1,] -13.141583 -8.328703 -0.2897115
## [2,]  -5.740346 -4.236548  0.1917577
## [3,]   8.812055  6.232118  0.6486406
```

As we can see, it didn't re-calculate the inverse, as it was already stored in the cache.

Now, if we try to get the inverse of a singular matrix, function **solve()** will return a warning:


```r
sing.matrix <- matrix(c(3,6,2,4), nrow=2, ncol=2)
spec.sing.matrix = makeCacheMatrix(sing.matrix)
spec.sing.matrix$get()
```

```
##      [,1] [,2]
## [1,]    3    2
## [2,]    6    4
```

```r
cacheSolve(spec.sing.matrix)
```

```
## Error in solve.default(matrix, ...): Lapack routine dgesv: system is exactly singular: U[2,2] = 0
```

We can improve **cacheSolve()** with a singularity check using
function **is.singular.matrix** from package **matrixcalc**:
<http://www.inside-r.org/packages/cran/matrixcalc/docs/is.singular.matrix>


```r
library(matrixcalc)

cacheSolve <- function(x, ...) {
  
  # Return a matrix that is the inverse of 'x'
  
  my_inv <- x$getinv()
  
  if(!is.null(my_inv))
  {
    message("Inverse matrix available in the cache...")
    return(my_inv)
  }
  
  matrix <- x$get()
  
  if (!is.singular.matrix(matrix)) {
    
    my_inv <- solve(matrix, ...)
    
    x$setinv(my_inv)
    
    my_inv
    
  } else {
    
    message("Cannot calculate the inverse of a singular matrix")
    
  }
  
  
}
```

Now the code will not try to calculate the inverse matrix:


```r
cacheSolve(spec.sing.matrix)
```

```
## Cannot calculate the inverse of a singular matrix
```




