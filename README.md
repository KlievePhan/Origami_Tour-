

# Origami Tour - App Specification

A cross-platform Flutter application designed to guide users through the art of origami with real-time progress tracking, advanced cataloging, and an interactive step-by-step folding viewer.

## Table of Contents

1. [Login Screen](https://www.google.com/search?q=%231-login-screen)
2. [Register Screen](https://www.google.com/search?q=%232-register-screen)
3. [Main Navigation (Menu Screen)](https://www.google.com/search?q=%233-main-navigation-menu-screen)
4. [Collection Screen](https://www.google.com/search?q=%234-collection-screen)
5. [Bookmark Screen](https://www.google.com/search?q=%235-bookmark-screen)
6. [Model Details Screen](https://www.google.com/search?q=%236-model-details-screen)
7. [Process View (Step-by-Step Tutorial)](https://www.google.com/search?q=%237-process-view-step-by-step-tutorial)
8. [Finish Screen & Time Records](https://www.google.com/search?q=%238-finish-screen--time-records)
9. [Profile & Achievement Screen](https://www.google.com/search?q=%239-profile--achievement-screen)

---

## 1. Login Screen

* **Purpose:** Secure user authentication via Google Auth or Email/Password credentials.
* **UI Components:**
* Centered App Logo & Branding.
* Email/Username field & Password field (with show/hide toggle).
* Primary "Login" button & Secondary "Sign in with Google" button.
* Hyperlinks: "Forgot Password?" and "Register New Account".
* Inline error messages & full-screen loading overlay during auth.


* **Flow:**
* Success $\rightarrow$ Navigates to **Collection Screen** (default tab).
* "Forgot Password?" $\rightarrow$ Navigates to **Forgot Password Screen**.
* "Register New Account" $\rightarrow$ Navigates to **Register Screen**.



## 2. Register Screen

* **Purpose:** Account creation for new users with real-time form validation.
* **UI Components:**
* Top-left Back button & "Create New Account" header.
* Inputs: Full Name, Email (format check), Password (min 8 chars, 1 uppercase, 1 number + strength meter), and Confirm Password (match check).
* Validation-tied "Register" primary button.
* Hyperlink: "Already have an account? Login here".


* **Flow:**
* Success $\rightarrow$ Automatically logs in and routes to **Main Navigation**.
* Login link / Back button $\rightarrow$ Returns to **Login Screen**.



## 3. Main Navigation (Menu Screen)

* **Purpose:** The global application shell hosting core core features.
* **UI Components:**
* **Header:** Circular user avatar, Display name, and Mastery rank badge (e.g., *Crane Apprentice · Lv.4*).
* **Bottom Navigation Bar:** 3 active tabs with distinct accent icons: Collection, Bookmark, Profile & Achievement.


* **Flow:**
* Tab taps switch sub-views instantly without full page reloads.
* Tapping the header avatar forces navigation to the Profile tab.



## 4. Collection Screen

* **Purpose:** Real-time searchable and filterable library of origami models.
* **UI Components:**
* Sticky search bar (**Search by Name**).
* Inline multi-select chips: Difficulty (Easy, Medium, Hard) & Categories (Animals, Birds, Flowers, Dinosaurs, etc.).
* Sort dropdown (Popularity, Newest, Shortest Time) & "Reset Filters" action.
* Global Progress Bar: Total finished models counter (e.g., *Finished: 12 / 48*).
* Toggleable 2-column Grid/List layout of Model Cards. Each card displays: Thumbnail, name, color-coded difficulty, time estimate, step count, and individual in-progress status bar.


* **Flow:**
* Typing or toggling filters updates the list dynamically via reactive state.
* Tapping any card $\rightarrow$ Navigates to **Model Details Screen**.



## 5. Bookmark Screen

* **Purpose:** Management of personal saved and active origami sessions.
* **UI Components:**
* Segmented controls splitting the view into two lists:
* **Favorites:** Saved models; supports sort (A-Z/Date) and swipe-to-delete.
* **In Progress:** Models mid-fold displaying step metrics (e.g., *Step 4 of 12*), percentage bars, and a "Last folded" timestamp.




* **Flow:**
* Tapping a Favorite card $\rightarrow$ Navigates to **Model Details Screen**.
* Tapping an In-Progress card $\rightarrow$ Hydrates **Model Details Screen** with restored historical state.
* Removing items triggers an immediate UI update backed by an "Undo" Snackbar.



## 6. Model Details Screen

* **Purpose:** Pre-session review of origami parameters and cultural history.
* **UI Components:**
* Back button & favorite toggle icon.
* Full-width zoomable hero image, model title, and creator credits.
* Specifications panel: Difficulty badge, recommended paper size/type, duration, and star ratings.
* Description block (Historical context) and a horizontal scrollable row of Step Thumbnails.
* Contextual Action Button: Reads **"Start Folding"** or **"Resume from Step X"**.


* **Flow:**
* Action Button $\rightarrow$ Launches **Process View** at target step index.
* Back button $\rightarrow$ Relocates user back to originating source screen.



## 7. Process View (Step-by-Step Tutorial)

* **Purpose:** Immersive, distraction-free folding dashboard.
* **UI Components:**
* Cancel ("X") button, Step counter (e.g., *Step 5 of 12*), and linear progress bar.
* Central content box: Zoomable vector fold diagram, short looping fold animation overlay, instructional block, and fold-type label (e.g., *Valley Fold*).
* Bottom Nav: "Previous" (disabled on step 1) and "Next" buttons. On the final step, "Next" mutates into **"Finish Tutorial"**.
* Background metrics engine tracking time spent per step.


* **Flow:**
* "Cancel" $\rightarrow$ Spawns save confirmation dialog $\rightarrow$ Navigates back to **Bookmark Screen** (In Progress tab).
* "Finish Tutorial" $\rightarrow$ Evaluates session metadata $\rightarrow$ Navigates to **Finish Screen**.



## 8. Finish Screen & Time Records

* **Purpose:** Performance summaries, rewards calculation, and leveling notifications.
* **UI Components:**
* Lottie celebration animation with completed model graphic.
* Session card: Total time elapsed, personal records milestones, and timestamp.
* Animated EXP delivery widget + Level-up banner (if applicable).
* Achievement unlock popup card stack (for newly unlocked badges).
* Core Actions: "View Profile" & "Back to Home".


* **Flow:**
* Native back gestures are intercepted and disabled; users must explicitly choose an action.
* "View Profile" $\rightarrow$ Navigates to **Profile Screen** with synchronized EXP animation.
* "Back to Home" $\rightarrow$ Returns to **Collection Screen**.



## 9. Profile & Achievement Screen

* **Purpose:** User account customization, historical analytics, and milestone tracking.
* **UI Components:**
* Profile Card: Editable avatar image (launches image picker), inline display name editor, and registration date.
* Progress Gauges: Total accumulated EXP metric, current rank title, and preview of the next rank.
* Statistics Matrix: Numerical counters for completed models, aggregate practice hours, favorite categories, and daily active streaks.
* Achievement Gallery: 3-column badge matrix. Unlocked badges render in full color with timestamps; locked badges remain grayscale with hint tooltips.
* Bottom "Logout" button with safety validation modal.


* **Flow:**
* Logout confirmation clears secure application state and drops connection back to **Login Screen**.
* Tapping elements (such as locked badges) prompts overlay tooltips without shifting focus away from the screen.# MyOrigamiTour
# OrigamiTour
# OrigamiTour
# Origami_Tour-
