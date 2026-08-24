///|
/// One closed-open histogram bin, with the final bin closed at the maximum.
pub struct HistogramBin {
  lower : Double
  upper : Double
  count : Int
} derive(Debug, Eq)

///|
/// A deterministic equal-width histogram of measured values.
pub struct Histogram {
  bins : Array[HistogramBin]
  total : Int
  minimum : Double
  maximum : Double
} derive(Debug, Eq)

///|
fn histogram_minimum(values : Array[Double]) -> Double {
  let mut minimum = 1.0e308
  for value in values {
    if value < minimum {
      minimum = value
    }
  }
  minimum
}

///|
fn histogram_maximum(values : Array[Double]) -> Double {
  let mut maximum = -1.0e308
  for value in values {
    if value > maximum {
      maximum = value
    }
  }
  maximum
}

///|
fn histogram_index(
  value : Double,
  minimum : Double,
  maximum : Double,
  width : Double,
  count : Int,
) -> Int {
  if minimum == maximum {
    0
  } else if value <= minimum {
    0
  } else if value >= maximum {
    count - 1
  } else {
    let index = ((value - minimum) / width).floor().to_int()
    if index < 0 {
      0
    } else if index >= count {
      count - 1
    } else {
      index
    }
  }
}

///|
/// Build an equal-width histogram with a fixed number of bins.
pub fn histogram(values : Array[Double], bin_count : Int) -> Histogram {
  if values.length() == 0 {
    abort("cannot build a histogram from an empty sample set")
  }
  if bin_count <= 0 {
    abort("histogram bin count must be positive")
  }
  let minimum = histogram_minimum(values)
  let maximum = histogram_maximum(values)
  let width = if minimum == maximum {
    1.0
  } else {
    (maximum - minimum) / bin_count.to_double()
  }
  let bins = []
  for index in 0..<bin_count {
    let lower = if minimum == maximum {
      minimum
    } else {
      minimum + index.to_double() * width
    }
    let upper = if minimum == maximum {
      maximum
    } else if index == bin_count - 1 {
      maximum
    } else {
      lower + width
    }
    bins.push({ lower, upper, count: 0 })
  }
  for value in values {
    let index = histogram_index(value, minimum, maximum, width, bin_count)
    let bin = bins[index]
    bins[index] = { lower: bin.lower, upper: bin.upper, count: bin.count + 1 }
  }
  { bins, total: values.length(), minimum, maximum }
}

///|
/// Count all observations represented by the bins.
pub fn Histogram::counted_samples(self : Histogram) -> Int {
  let mut total = 0
  for bin in self.bins {
    total += bin.count
  }
  total
}

///|
/// Return the fraction of observations at or below a value.
pub fn Histogram::cumulative_fraction(
  self : Histogram,
  value : Double,
) -> Double {
  if value < self.minimum {
    0.0
  } else if value >= self.maximum {
    1.0
  } else {
    let mut count = 0
    for bin in self.bins {
      if value >= bin.upper {
        count += bin.count
      } else if value >= bin.lower {
        count += bin.count / 2
        break
      } else {
        break
      }
    }
    count.to_double() / self.total.to_double()
  }
}

///|
/// Estimate a percentile by interpolating within its containing bin.
pub fn Histogram::percentile(self : Histogram, probability : Double) -> Double {
  if probability < 0.0 || probability > 1.0 {
    abort("histogram percentile must be between zero and one")
  }
  if self.minimum == self.maximum {
    self.minimum
  } else {
    let target = probability * (self.total - 1).to_double()
    let mut before = 0
    let mut result = self.maximum
    for bin in self.bins {
      let after = before + bin.count
      if target < after.to_double() {
        let within = if bin.count == 0 {
          0.0
        } else {
          (target - before.to_double()) / bin.count.to_double()
        }
        result = bin.lower + (bin.upper - bin.lower) * within
        break
      }
      before = after
    }
    result
  }
}

///|
/// Return the bin index containing a value, clamped to the histogram range.
pub fn Histogram::bin_for(self : Histogram, value : Double) -> Int {
  let width = if self.minimum == self.maximum {
    1.0
  } else {
    (self.maximum - self.minimum) / self.bins.length().to_double()
  }
  histogram_index(value, self.minimum, self.maximum, width, self.bins.length())
}

///|
/// Return the count of one bin by index.
pub fn Histogram::frequency(self : Histogram, index : Int) -> Int {
  if index < 0 || index >= self.bins.length() {
    abort("histogram bin index out of range")
  }
  self.bins[index].count
}
