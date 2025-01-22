# My AI Gateway

**My AI Gateway** is a robust and customizable Flutter-based application designed to interact with
various AI model providers such as OpenAI and Hugging Face. It serves as a user-friendly gateway to
access, manage, and utilize AI models for a wide range of applications, including research,
development, and production environments.

---

## Features

- Fetch and display AI model details from providers (e.g., OpenAI, Hugging Face).
- Support for multiple providers with customizable configurations.
- Set default providers and models for streamlined access.
- Retrieve and display model-specific details based on the provider.
- Open links to model documentation or public pages directly in a browser.
- Handle large messages with multiline text input.

---

## Installation

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- A compatible IDE (e.g., Android Studio, Visual Studio Code)
- Internet access to fetch model details from providers like Hugging Face or OpenAI.

### Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/codycody31/my-ai-gateway.git
   cd my-ai-gateway
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the Application**
   ```bash
   flutter run
   ```

---

## Usage

### Initial Setup

1. Navigate to the **Settings** page.
2. Add your preferred provider (e.g., OpenAI, Hugging Face) by specifying:
    - Provider name
    - API URL
    - Authentication token (if required)
3. Set a default provider for quick access.

### Chatting with AI Models

1. Select a model from the dropdown menu.
2. Enter your prompt or query in the text box.
3. View real-time or complete responses based on your settings.

### Managing Providers

- Use the **Providers** section in the settings to add, edit, or remove providers.

---

## Contributions

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Submit a pull request with detailed descriptions of your changes.

---

## License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).

---

## Support

For issues or feature requests, please open an issue
on [GitHub](https://github.com/codycody31/my-ai-gateway/issues).

---

## Acknowledgments

- [Flutter](https://flutter.dev/)
- [OpenAI](https://platform.openai.com/)
- [Hugging Face](https://huggingface.co/)