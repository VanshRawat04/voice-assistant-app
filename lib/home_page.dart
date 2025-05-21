import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_assistant_app/feature_box.dart';
import 'package:voice_assistant_app/openai_service.dart';
import 'package:voice_assistant_app/pallete.dart';

// ✅ Add this class back
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  final List<String> messages = [];

  @override
  void initState() {
    super.initState();
    intiSpeechToText();
  }

  Future<void> intiSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    // Reset conversation when starting a new listen
    setState(() {
      messages.clear();
      messages.add("🆕 New conversation started");
      lastWords = '';
    });

    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  @override
  void dispose() {
    speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voice Assistant"),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Assistant image and intro
            Stack(
              children: [
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: Pallete.assistantCircleColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                  height: 125,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/virtualAssistant.png'),
                    ),
                  ),
                )
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              margin:
                  const EdgeInsets.symmetric(horizontal: 40).copyWith(top: 30),
              decoration: BoxDecoration(
                border: Border.all(color: Pallete.borderColor),
                borderRadius:
                    BorderRadius.circular(20).copyWith(topLeft: Radius.zero),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "Good Morning, what task can  I do for you ?",
                  style: TextStyle(
                    color: Pallete.mainFontColor,
                    fontSize: 24,
                    fontFamily: "Cera Pro",
                  ),
                ),
              ),
            ),

            // Suggestions
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 10, left: 22),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Here are a few suggestions",
                  style: TextStyle(
                    fontFamily: 'Cera Pro',
                    color: Pallete.mainFontColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Column(
              children: [
                FeatureBox(
                  color: Pallete.firstSuggestionBoxColor,
                  headerText: 'ChatGPT',
                  descriptionText:
                      'A smarter way to stay organized and informed with ChatGPT',
                ),
                FeatureBox(
                  color: Pallete.secondSuggestionBoxColor,
                  headerText: 'Dall-E',
                  descriptionText:
                      'GET inspired and stay creative with your personal assistant powered by Dall-E',
                ),
                FeatureBox(
                  color: Pallete.thirdSuggestionBoxColor,
                  headerText: 'Smart Voice Assistant',
                  descriptionText:
                      'Get the best of both worlds with a voice assistant powerd by Dall-E and ChatGPT',
                ),
              ],
            ),

            // 💬 Chat messages area
            const SizedBox(height: 20),
            const Text(
              'Conversation',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Cera Pro',
                fontWeight: FontWeight.bold,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: messages.length,
              itemBuilder: (context, index) => Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Pallete.firstSuggestionBoxColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  messages[index],
                  style: const TextStyle(
                    fontFamily: 'Cera Pro',
                    fontSize: 16,
                    color: Pallete.mainFontColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (await speechToText.hasPermission && speechToText.isNotListening) {
            await startListening();
          } else if (speechToText.isListening) {
            await stopListening();
            setState(() {
              if (lastWords.trim().isNotEmpty) {
                messages.add("🗣️ $lastWords");
              }
            });
            await openAIService.isArtPromptAPI(lastWords);
          } else {
            intiSpeechToText();
          }
        },
        backgroundColor: Pallete.firstSuggestionBoxColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.mic),
      ),
    );
  }
}
