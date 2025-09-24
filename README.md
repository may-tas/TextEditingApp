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
│   │   ├── canvas_screen.dart
│   │   ├── save_page_dialog.dart
│   │   ├── saved_pages.dart
│   │   └── splash_screen.dart
│   └── widgets/
│       ├── background_color_tray.dart
│       ├── background_options_sheet.dart
│       ├── editable_text_widget.dart
│       └── font_controls.dart
├──utils/
│    └──custom_snackbar.dart
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

### Text Alignment 

- Lets you control how your text is positioned horizontally

### Highlight 

- Add highlighted colors to your text for dynamic view

### Copy 

- Copy the text

### Restore Default

- Lets user to go back to the default view for the text

## Demo Video

https://github.com/user-attachments/assets/7ca08eff-dcbe-45c6-b0f1-502829ae8ffd


https://github.com/user-attachments/assets/4ed54a04-b887-42a3-a0a4-dd3dbdcf9320



### Font Controls UI

<img  src="https://github.com/user-attachments/assets/b575b132-6d9c-4983-9b83-66b915d1526f" alt="image"  width="200" height="400"/>

<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/043cbb05-51c1-452c-9c34-737251df0553" />

<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/11549c45-9fae-4be9-90ba-49596a8e7b45" />

<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/47c7f46e-25f3-4f01-a41c-7566c8e3633d" />

<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/e0bda0a2-e7e8-4941-85ce-1679cfbbac51" />

<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/f302a0e4-0128-40a4-a330-08d12814ccd5" />


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
            <td align="center">
                <a href="https://github.com/may-tas">
                    <img src="https://avatars.githubusercontent.com/u/135056339?v=4" width="100;" alt="may-tas"/>
                    <br />
                    <sub><b>Satyam Jha</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/sandy4242">
                    <img src="https://avatars.githubusercontent.com/u/152861071?v=4" width="100;" alt="sandy4242"/>
                    <br />
                    <sub><b>Sandeep Sarkar</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/PearlGrell">
                    <img src="https://avatars.githubusercontent.com/u/185500672?v=4" width="100;" alt="PearlGrell"/>
                    <br />
                    <sub><b>Aryan Trivedi</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/MannemSumanaSri">
                    <img src="https://avatars.githubusercontent.com/u/204357939?v=4" width="100;" alt="MannemSumanaSri"/>
                    <br />
                    <sub><b>Mannem Sumana Sri</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/Manar-Elhabbal7">
                    <img src="https://avatars.githubusercontent.com/u/172148857?v=4" width="100;" alt="Manar-Elhabbal7"/>
                    <br />
                    <sub><b>Manar ELhabbal</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/Atomic-Shadow7002">
                    <img src="https://avatars.githubusercontent.com/u/191123414?v=4" width="100;" alt="Atomic-Shadow7002"/>
                    <br />
                    <sub><b>Abhishek Kumar Ray</b></sub>
                </a>
            </td>
		</tr>
		<tr>
            <td align="center">
                <a href="https://github.com/Elwin-p">
                    <img src="https://avatars.githubusercontent.com/u/150349344?v=4" width="100;" alt="Elwin-p"/>
                    <br />
                    <sub><b>Elwin</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/preetidas60">
                    <img src="https://avatars.githubusercontent.com/u/112088836?v=4" width="100;" alt="preetidas60"/>
                    <br />
                    <sub><b>Preeti Das</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/pranayshl">
                    <img src="https://avatars.githubusercontent.com/u/163889726?v=4" width="100;" alt="pranayshl"/>
                    <br />
                    <sub><b>pranayshl</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/ishita051">
                    <img src="https://avatars.githubusercontent.com/u/183702036?v=4" width="100;" alt="ishita051"/>
                    <br />
                    <sub><b>Ishita Srivastava | Contributor</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/zxnb01">
                    <img src="https://avatars.githubusercontent.com/u/141150925?v=4" width="100;" alt="zxnb01"/>
                    <br />
                    <sub><b>Shaik Zainab</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/Rudraksha-git">
                    <img src="https://avatars.githubusercontent.com/u/175207612?v=4" width="100;" alt="Rudraksha-git"/>
                    <br />
                    <sub><b>Rudraksha kumar</b></sub>
                </a>
            </td>
		</tr>
		<tr>
            <td align="center">
                <a href="https://github.com/Rishi-1512">
                    <img src="https://avatars.githubusercontent.com/u/122536214?v=4" width="100;" alt="Rishi-1512"/>
                    <br />
                    <sub><b>Ritam Sen</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/GauriRocksies">
                    <img src="https://avatars.githubusercontent.com/u/178488305?v=4" width="100;" alt="GauriRocksies"/>
                    <br />
                    <sub><b>GAURI</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/debasmitaas">
                    <img src="https://avatars.githubusercontent.com/u/189460298?v=4" width="100;" alt="debasmitaas"/>
                    <br />
                    <sub><b>Debasmita C</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/DMounas">
                    <img src="https://avatars.githubusercontent.com/u/212203186?v=4" width="100;" alt="DMounas"/>
                    <br />
                    <sub><b>DMounas</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/AnanyaSingh456">
                    <img src="https://avatars.githubusercontent.com/u/184369984?v=4" width="100;" alt="AnanyaSingh456"/>
                    <br />
                    <sub><b>Ananya Singh</b></sub>
                </a>
            </td>
		</tr>
	<tbody>
</table>
<!-- readme: contributors -start -->
<table>
	<tbody>
		<tr>
            <td align="center">
                <a href="https://github.com/may-tas">
                    <img src="https://avatars.githubusercontent.com/u/135056339?v=4" width="100;" alt="may-tas"/>
                    <br />
                    <sub><b>Satyam Jha</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/PearlGrell">
                    <img src="https://avatars.githubusercontent.com/u/185500672?v=4" width="100;" alt="PearlGrell"/>
                    <br />
                    <sub><b>Aryan Trivedi</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/MannemSumanaSri">
                    <img src="https://avatars.githubusercontent.com/u/204357939?v=4" width="100;" alt="MannemSumanaSri"/>
                    <br />
                    <sub><b>Mannem Sumana Sri</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/Manar-Elhabbal7">
                    <img src="https://avatars.githubusercontent.com/u/172148857?v=4" width="100;" alt="Manar-Elhabbal7"/>
                    <br />
                    <sub><b>Manar ELhabbal</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/Atomic-Shadow7002">
                    <img src="https://avatars.githubusercontent.com/u/191123414?v=4" width="100;" alt="Atomic-Shadow7002"/>
                    <br />
                    <sub><b>Abhishek Kumar Ray</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/Elwin-p">
                    <img src="https://avatars.githubusercontent.com/u/150349344?v=4" width="100;" alt="Elwin-p"/>
                    <br />
                    <sub><b>Elwin</b></sub>
                </a>
            </td>
		</tr>
		<tr>
            <td align="center">
                <a href="https://github.com/preetidas60">
                    <img src="https://avatars.githubusercontent.com/u/112088836?v=4" width="100;" alt="preetidas60"/>
                    <br />
                    <sub><b>Preeti Das</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/sandy4242">
                    <img src="https://avatars.githubusercontent.com/u/152861071?v=4" width="100;" alt="sandy4242"/>
                    <br />
                    <sub><b>Sandeep Sarkar</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/AnanyaSingh456">
                    <img src="https://avatars.githubusercontent.com/u/184369984?v=4" width="100;" alt="AnanyaSingh456"/>
                    <br />
                    <sub><b>Ananya Singh</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/DMounas">
                    <img src="https://avatars.githubusercontent.com/u/212203186?v=4" width="100;" alt="DMounas"/>
                    <br />
                    <sub><b>DMounas</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/debasmitaas">
                    <img src="https://avatars.githubusercontent.com/u/189460298?v=4" width="100;" alt="debasmitaas"/>
                    <br />
                    <sub><b>Debasmita C</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/GauriRocksies">
                    <img src="https://avatars.githubusercontent.com/u/178488305?v=4" width="100;" alt="GauriRocksies"/>
                    <br />
                    <sub><b>GAURI</b></sub>
                </a>
            </td>
		</tr>
		<tr>
            <td align="center">
                <a href="https://github.com/Rishi-1512">
                    <img src="https://avatars.githubusercontent.com/u/122536214?v=4" width="100;" alt="Rishi-1512"/>
                    <br />
                    <sub><b>Ritam Sen</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/Rudraksha-git">
                    <img src="https://avatars.githubusercontent.com/u/175207612?v=4" width="100;" alt="Rudraksha-git"/>
                    <br />
                    <sub><b>Rudraksha kumar</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/Charmiseera">
                    <img src="https://avatars.githubusercontent.com/u/157686006?v=4" width="100;" alt="Charmiseera"/>
                    <br />
                    <sub><b>Seera charmi</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/zxnb01">
                    <img src="https://avatars.githubusercontent.com/u/141150925?v=4" width="100;" alt="zxnb01"/>
                    <br />
                    <sub><b>Shaik Zainab</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/ishita051">
                    <img src="https://avatars.githubusercontent.com/u/183702036?v=4" width="100;" alt="ishita051"/>
                    <br />
                    <sub><b>Ishita Srivastava | Contributor</b></sub>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/pranayshl">
                    <img src="https://avatars.githubusercontent.com/u/163889726?v=4" width="100;" alt="pranayshl"/>
                    <br />
                    <sub><b>pranayshl</b></sub>
                </a>
            </td>
		</tr>
	<tbody>
</table>
<!-- readme: contributors -end -->





## Maintainers

- **Satyam Jha**
  - [github](https://github.com/may-tas)
  - [linkedIn](linkedin.com/in/satyam-jha-7746201a4/)

## Contact

For questions or suggestions, feel free to contact:

- **Author:** Satyam Jha
- **Email:** <satyamj210@gmail.com>
