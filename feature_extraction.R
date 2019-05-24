#import library
require(signal)
require(edf)
library(aTSA)
library(rlist)
library(pracma)
library(nonlinearTseries)
library(TSEntropies)
#load datasets
file1 <- './chb05_12.edf'
file2 <- './chb05_13S.edf'
file3 <- './chb05_14.edf'

s1 <- read.edf(file1)
s2 <- read.edf(file2)
s3 <- read.edf(file3)

s1$signal$T8_P8 <- NULL
s2$signal$T8_P8 <- NULL
s3$signal$T8_P8 <- NULL

#clean from noise
#plot(s1$signal$FP1_F7$data[1:2000], type = 'l')
SAMPLE_FREQUENCY = 256
RADIANS = 1/(2*pi)
NYQUIST = SAMPLE_FREQUENCY * 0.5

#filters
lowpass <- function(freq){
  f <- butter(5, RADIANS*freq/NYQUIST, type="low", plane = 'z')
  return(f)
}
stoppass <- function(freq1, freq2){
  f <- butter(5, c(RADIANS*freq1/NYQUIST,RADIANS*freq2/NYQUIST), type="stop", plane = 'z')
  return(f)
}
highpass <- function(freq){
  f <- butter(5, RADIANS*freq/NYQUIST, type="high", plane = 'z')
  return(f)
}
clean_main_signal <- function(signal){
  bf1 <- butter(5, RADIANS*125/NYQUIST, type="low", plane = 'z')
  bf2 <- butter(5, c(RADIANS*58/NYQUIST,RADIANS*62/NYQUIST), type="stop", plane = 'z')
  first_transform <- filtfilt(lowpass(125), signal)
  signal <- filtfilt(stoppass(58,62), first_transform)
  return(signal)
}

#if you want to divide signal in different frequencies
delta <- function(signal){
  delta <- filtfilt(lowpass(4), signal)
  return(delta)
}
theta <- function(signal){
  theta1 <- filtfilt(highpass(4), signal)
  theta <- filtfilt(lowpass(8), theta1)
  return(theta)
}
alpha <- function(signal){
  alpha1 <- filtfilt(highpass(8), signal)
  alpha <- filtfilt(lowpass(14), alpha1)
  return(alpha)
}
beta <- function(signal){
  beta <- filtfilt(highpass(14), signal)
  return(beta)
}

#################CREATE DATAFRAME################################

dataset <- data.frame(window=integer(),signal_mean=numeric(),
                      signal_std=numeric(), hurst=numeric(), entropy=numeric())
TIME_WINDOW <- 6
windows_1 <- list()
windows_2 <- list()
windows_3 <- list()
samples <- SAMPLE_FREQUENCY*TIME_WINDOW

#########SPLIT DATA IN WINDOWS#####################
for(sensor in s1$signal){
  #first divide data in intervals of 6 seconds
  sensor$data <- clean_main_signal(sensor$data)
  x <- seq_along(sensor$data)
  sensor_data <- split(sensor$data, ceiling(x/samples))
  windows_1 <- c(windows_1, sensor_data)
}
for(sensor in s2$signal){
  #first divide data in intervals of 6 seconds
  sensor$data <- clean_main_signal(sensor$data)
  x <- seq_along(sensor$data)
  sensor_data <- split(sensor$data, ceiling(x/samples))
  windows_2 <- c(windows_2, sensor_data)
}
for(sensor in s3$signal){
  #first divide data in intervals of 6 seconds
  sensor$data <- clean_main_signal(sensor$data)
  x <- seq_along(sensor$data)
  sensor_data <- split(sensor$data, ceiling(x/samples))
  windows_3 <- c(windows_3, sensor_data)
}

############################
#split windows in sensors
n_sensors <- 22
x <- seq_along(windows_1)
sensor_data <- split(windows_1, ceiling(x/n_sensors))

for(number in seq(1,length(sensor_data))){
  for(i in seq(1, length(sensor_data[[number]]))){
    row <- data.frame(window = number, signal_mean = mean(sensor_data[[number]][[i]]), signal_std = sd(sensor_data[[number]][[i]]),
                      hurst = hurstexp(sensor_data[[number]][[i]])$Hs, entropy = SampEn(sensor_data[[number]][[i]]))
    dataset <- rbind(dataset, row)
  }
}

x <- seq_along(windows_2)
sensor_data <- split(windows_2, ceiling(x/n_sensors))

for(number in seq(1,length(sensor_data))){
  for(i in seq(1, length(sensor_data[[number]]))){
    row <- data.frame(window = number, signal_mean = mean(sensor_data[[number]][[i]]), signal_std = sd(sensor_data[[number]][[i]]),
                      hurst = hurstexp(sensor_data[[number]][[i]])$Hs, entropy = SampEn(sensor_data[[number]][[i]]))
    dataset <- rbind(dataset, row)
  }
}

x <- seq_along(windows_3)
sensor_data <- split(windows_3, ceiling(x/n_sensors))

for(number in seq(1,length(sensor_data))){
  for(i in seq(1, length(sensor_data[[number]]))){
    row <- data.frame(window = number, signal_mean = mean(sensor_data[[number]][[i]]), signal_std = sd(sensor_data[[number]][[i]]),
                      hurst = hurstexp(sensor_data[[number]][[i]])$Hs, entropy = SampEn(sensor_data[[number]][[i]]))
    dataset <- rbind(dataset, row)
  }
}
write.csv(dataset, 'dataset_eeg.csv')
