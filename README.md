# Text Editing App
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-16-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

This project provides an interactive user interface to control font properties such as font size, font family, font color, and font style. Built using Flutter and Bloc for state management, it ensures a modern, responsive, and smooth user experience.

## Features

- **Font Size Control:**
  - Increase or decrease font size dynamically using intuitive buttons.
- **Font Family Selection:**
  - Change font family via a dropdown menu with predefined options.
- **Font Color Control:**
  - Select a font color from a palette of predefined colors.
- **Font Style Selection:**
  - Switch between different font styles (e.g., bold, italic).
- **Responsive UI:**
  - Smooth horizontal scrolling and adaptive design for various screen sizes.

## Technologies Used

- **Flutter:** Framework for UI development.
- **Cubit:** State management for dynamic changes.
- **Dart:** Programming language.
- **Material Design:** For sleek and intuitive UI components.


## Platform Support

| Platform | Status | Version |
|----------|--------|---------|
| <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/android/android-original.svg" alt="Android" width="20"/> Android | ✅ Supported | API 33+ |
| <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/apple/apple-original.svg" alt="iOS" width="20"/> iOS | ✅ Supported | iOS 17+ |
| <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/chrome/chrome-original.svg" alt="Web" width="20"/> Web | ✅ Supported | Modern Browsers |


## How to Run

1. Clone the repository:

   ```bash
   git clone <repository-url>
   ```

2. Navigate to the project directory:

   ```bash
   cd project directory
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Run the app:

   ```bash
   flutter run
   ```

## Folder Structure

```plaintext
lib/
├── constants/
│   └── font_family_list.dart
├── cubit/
│   ├── canvas_cubit.dart
│   └── canvas_state.dart
├── models/
│   └── text_item_model.dart
├── ui/
│   ├── screens/
│   │   └── canvas_screen.dart
│   ├── widgets/
│   │   ├── editable_text_widget.dart
│   │   └── font_controls.dart
├── main.dart
```

### Folder Details

- **constants**: Contains app-wide constant values.
  - `font_family_list.dart`: List of available font families.
- **cubit**: Manages application state using the Cubit package.
  - `canvas_cubit.dart`: Handles business logic for canvas operations.
  - `canvas_state.dart`: Defines the state of the canvas.
- **models**: Contains data models used in the app.
  - `text_item_model.dart`: Model representing text items on the canvas.
- **ui**: Contains user interface components.
  - **screens**: Holds all screen-related files.
    - `canvas_screen.dart`: Main screen where the canvas is displayed.
  - **widgets**: Reusable UI components.
    - `editable_text_widget.dart`: Widget for editable text items.
    - `font_controls.dart`: Widget for controlling font properties.
- `main.dart`: Entry point of the application.

## Prerequisites

- Flutter SDK
- Dart SDK

## Usage

### Font Size Control

- Use the `+` and `-` buttons to adjust the font size.

### Font Family Selection

- Select a font from the dropdown menu to update the displayed text.

### Font Color Control

- Choose a color from the palette to change the text color.

### Font Style Selection

- Add bold, italic styles to your text using additional controls.

## Demo Video

https://github.com/user-attachments/assets/7ca08eff-dcbe-45c6-b0f1-502829ae8ffd

### Font Controls UI

<img src="https://github.com/user-attachments/assets/abaca11c-81b8-4931-ba63-2b9ee7212c82" alt="Screenshot" width="200" height="400">

<img src="https://github.com/user-attachments/assets/08072113-6459-4874-980c-e9cf61fd9ea1" alt="Screenshot" width="200" height="400">

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bugfix:

   ```bash
   git checkout -b feature-name
   ```

3. Commit your changes:

   ```bash
   git commit -m "Add some feature"
   ```

4. Push to your branch:

   ```bash
   git push origin feature-name
   ```

5. Open a pull request.

## Support

🌟 If you find this project helpful, please consider giving it a star! \
It helps others discover the project and motivates us to keep improving. Your support means a lot! 🙌

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.


## Acknowledgments

Special thanks to:

- [Flutter Team](https://flutter.dev/) for the amazing framework
- [Bloc Library](https://bloclibrary.dev/) for state management
- [Material Design](https://material.io/) for design guidelines
- All our [contributors](#contributors) for making this project better
- The open-source community for inspiration and support



## Contributors

<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/may-tas"><img src="https://avatars.githubusercontent.com/u/135056339?v=4?s=100" width="100px;" alt="Satyam Jha"/><br /><sub><b>Satyam Jha</b></sub></a><br /> </td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/PearlGrell"><img src="https://avatars.githubusercontent.com/u/185500672?v=4?s=100" width="100px;" alt="Aryan Trivedi"/><br /><sub><b>Aryan Trivedi</b></sub></a><br /></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/MannemSumanaSri"><img src="https://avatars.githubusercontent.com/u/204357939?v=4?s=100" width="100px;" alt="Mannem Sumana Sri"/><br /><sub><b>Mannem Sumana Sri</b></sub></a><br /></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Manar-Elhabbal7"><img src="https://avatars.githubusercontent.com/u/172148857?v=4?s=100" width="100px;" alt="Manar ELhabbal"/><br /><sub><b>Manar ELhabbal</b></sub></a><br /></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Atomic-Shadow7002"><img src="https://avatars.githubusercontent.com/u/191123414?v=4?s=100" width="100px;" alt="Abhishek Kumar Ray"/><br /><sub><b>Abhishek Kumar Ray</b></sub></a><br /></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Elwin-p"><img src="https://avatars.githubusercontent.com/u/150349344?v=4?s=100" width="100px;" alt="Elwin"/><br /><sub><b>Elwin</b></sub></a><br /></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/preetidas60"><img src="https://avatars.githubusercontent.com/u/112088836?v=4?s=100" width="100px;" alt="Preeti Das"/><br /><sub><b>Preeti Das</b></sub></a><br /></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/AnanyaSingh456"><img src="https://avatars.githubusercontent.com/u/184369984?v=4?s=100" width="100px;" alt="Ananya Singh"/><br /><sub><b>Ananya Singh</b></sub></a><br /></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/DMounas"><img src="https://avatars.githubusercontent.com/u/212203186?v=4?s=100" width="100px;" alt="DMounas"/><br /><sub><b>DMounas</b></sub></a><br /></td>
      <td align="center" valign="top" width="14.28%"><a href="https://debasmitas-portfolio.netlify.app/"><img src="https://avatars.githubusercontent.com/u/189460298?v=4?s=100" width="100px;" alt="Debasmita C"/><br /><sub><b>Debasmita C</b></sub></a><br /></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/GauriRocksies"><img src="https://avatars.githubusercontent.com/u/178488305?v=4?s=100" width="100px;" alt="GAURI"/><br /><sub><b>GAURI</b></sub></a><br /></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Rishi-1512"><img src="https://avatars.githubusercontent.com/u/122536214?v=4?s=100" width="100px;" alt="Ritam Sen"/><br /><sub><b>Ritam Sen</b></sub></a><br /></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Rudraksha-git"><img src="https://avatars.githubusercontent.com/u/175207612?v=4?s=100" width="100px;" alt="Rudraksha kumar"/><br /><sub><b>Rudraksha kumar</b></sub></a><br /></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/zxnb01"><img src="https://avatars.githubusercontent.com/u/141150925?v=4?s=100" width="100px;" alt="Shaik Zainab"/><br /><sub><b>Shaik Zainab</b></sub></a><br /></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ishita051"><img src="https://avatars.githubusercontent.com/u/183702036?v=4?s=100" width="100px;" alt="Ishita Srivastava &#124; Contributor"/><br /><sub><b>Ishita Srivastava &#124; Contributor</b></sub></a><br /></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/pranayshl"><img src="https://avatars.githubusercontent.com/u/163889726?v=4?s=100" width="100px;" alt="pranayshl"/><br /><sub><b>pranayshl</b></sub></a><br /></td>
    </tr>
  </tbody>
  <tfoot>
</table>





## Maintainers

- **Satyam Jha**
  - [github](https://github.com/may-tas)
  - [linkedIn](linkedin.com/in/satyam-jha-7746201a4/)

## Contact

For questions or suggestions, feel free to contact:

- **Author:** Satyam Jha
- **Email:** <satyamj210@gmail.com>
