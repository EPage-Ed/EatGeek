# EatGeek

*Overview:*
<Please describe this product or service including any machine learning models used>

EatGeek is a tool for making lifestyle dietary decisions. The EatGeek app allows a user to take a picture of a restaurant menu and returns highlighted recommendations on the image for menu items that are satisfactory, have issues, or require further inquiry based on the personalized dietary conditions set by the user. The user can tap a highlighted menu item for further details.

We have initially targeted EatGeek at people with Diabetes, or a pre-Diabetes diagnosis. Though it has applications for users with any condition requiring dietary monitoring such as Chrone's, renal diet (kidney failure), allergens, etc. Even people who just desire choice guidance such as vegetarian, low-carb, etc. would find EatGeek useful.

The EatGeek iOS app uses numerous technologies to achieve its features. The Vision framework is used to isolate text strings from an image, which are combined to formulate menu items. The text string regions are extracted from the image and passed through OCR. We are currently using Tesseract in-app for the OCR, but the Google Vision service would be an alternative. We are using OpenCV and GPUImage to massage the text blocks for better recognition.

The EatGeek iOS app also pulls information from HealthKit to better inform the user and improve recommendations. For example, a user with diabetes can record their glucose levels using whatever method they prefer. This information gets stored by HealthKit, and the EatGeek app asks for permission to access it.

We used a multinomial naive bayes algorthim implemented as part of SciKit learn. We leveraged word vector counts to fit our descriptions to sugar and carb ranges. We used a data set from the USDA to train the model. It included 7,500 data points. In order to choose the ranges that we used for sugar and carb quantities, we used Jenks Natural Breaks, an algorithm suited to one dimensional clustering.

The naive bayes approach is a good way to get reliable matches going quickly, but in the long run, we would want to use deep learning language models to understand relationships between menu descriptions and nutrition information. To get the data we need, we would look for a combination of published restaurant nutrition information, online recipies and the possiblity of generating recipies with a GANN using ingredients with known nutritional values to sum up and train on.


*Key Technologies:*
<for example: Flask, Tensor Flow, Keras>

iOS: Vision Framework, CoreML, OpenCV, GPUImage, Tesseract

ML: Scikitlearn

*Steps to Build and Test:*
<Please list and describe all steps necessary to build and run this product/service>

Jupyter Notebook to run the Baysian Inference engine created with Scikitlearn.

Cocoapods to pull in iOS libraries
 - may need to adjust Swift version for some pods like CameraManager (should be Swift 4, not 4.2) in the build settings.
 
Xcode to build the iOS app
 - must be run on a device due to the use of a camera.
 
We have only tested the app with a menu we printed from Friday's, and even then only a portion of the menu. More time is all that is needed to expand the scope.

Launch the app, point the camera at the menu, and tap the TAKE button. The app will show the resulting image and highlight portions it can identify as menu items. You can tap items to get more info. Tap the info to dismiss, and tap the menu image elsewhere to dismiss it.

