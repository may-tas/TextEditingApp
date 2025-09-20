# Text Editing App
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-1-orange.svg?style=flat-square)](#contributors-)
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

https://github.com/user-attachments/assets/518765d8-d2f0-4491-9385-69f1281c051c

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

## Maintainers
- **Satyam Jha**
  - [github](https://github.com/may-tas)
  - [linkedIn](linkedin.com/in/satyam-jha-7746201a4/)

## Contact

For questions or suggestions, feel free to contact:

- **Author:** Satyam Jha
- **Email:** satyamj210@gmail.com

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/may-tas"><img src="https://avatars.githubusercontent.com/u/135056339?v=4?s=100" width="100px;" alt="Satyam Jha"/><br /><sub><b>Satyam Jha</b></sub></a><br /><a href="https://github.com/may-tas/TextEditingApp/commits?author=may-tas" title="Code">💻</a> <a href="https://github.com/may-tas/TextEditingApp/commits?author=may-tas" title="Documentation">📖</a> <a href="#maintenance-may-tas" title="Maintenance">🚧</a> <a href="#design-may-tas" title="Design">🎨</a></td>
    </tr>
  </tbody>
  <tfoot>
    <tr>
      <td align="center" size="13px" colspan="7">
        <img src="https://raw.githubusercontent.com/all-contributors/all-contributors-cli/1b8533af435da9854653492b1327a23a4dbd0a10/assets/logo-small.svg">
          <a href="https://all-contributors.js.org/docs/en/bot/usage">Add your contributions</a>
        </img>
      </td>
    </tr>
  </tfoot>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!