import 'package:flutter/material.dart';

const Color kTeal = Color(0xFF137C76);
const Color kTealDark = Color(0xFF0E5E59);



class CareChatScreen extends StatefulWidget {
  final String? selectedTopic;

  const CareChatScreen({super.key, this.selectedTopic});

  @override
  State<CareChatScreen> createState() => _CareChatScreenState();
}


class _CareChatScreenState extends State<CareChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Suggested symptoms list
  final List<String> quickSymptoms = [
    "Fever",
    "Headache",
    "Chest Pain",
    "Skin Rash",
    "Stomach Pain",
    "Cough",
    "Diabetes",
    "Eye Pain",
  ];

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text:
      "👋 Hello! I'm Care AI.\n\nTap a symptom below or describe how you're feeling:\n👇",
      isUser: false,
    ),
  ];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
    });

    _controller.clear();
    _scrollToBottom();
    _botReply(text);
  }

  void _botReply(String userText) {
    final msg = userText.toLowerCase().trim();
    String reply = "";

    // ---------- BASIC HUMAN GREETINGS ----------
    if (msg == "hi" || msg == "hello" || msg == "hey" || msg == "hii") {
      reply = "👋 Hello! I'm **Care AI**.\n\nI help you:\n• Understand symptoms\n• Suggest right doctors\n• Guide health questions\n\nTell me how you're feeling 😊";
    }

    // ---------- WHO ARE YOU / WHAT CAN YOU DO ----------
    else if (msg.contains("who are you") || msg.contains("what are you")) {
      reply =
      "🤖 I'm **Care AI Assistant**.\n\nI'm here to help you with:\n• Understanding medical symptoms\n• Suggesting suitable specialist doctors\n• Giving basic health guidance\n\nJust tell me a symptom like:\n➡️ *I have fever*\n➡️ *Chest pain*\n➡️ *Skin allergy*";
    }

    // ---------- THANK YOU RESPONSE ----------
    else if (msg.contains("thank")) {
      reply = "😊 You're welcome! I'm here whenever you need help.";
    }

    // ---------- BYE / EXIT ----------
    else if (msg.contains("bye") || msg.contains("goodbye") || msg.contains("exit")) {
      reply = "👋 Goodbye!\nTake care and feel free to return anytime 💙";
    }

    // ---------- SYMPTOM DETECTION ----------
    else if (msg.contains("headache") || msg.contains("migraine")) {
      reply =
      "🧠 Headache detected.\nLikely causes:\n- Stress\n- Dehydration\n- Migraine\n\n👨‍⚕️ Recommended: **Neurologist**.\n\n💡 Tip: Drink water and rest in a dark quiet room.";
    }

    else if (msg.contains("fever")) {
      reply =
      "🌡️ Fever detected.\nPossible causes:\n• Viral infection\n• Flu\n\n👨‍⚕️ Best doctor: **General Physician**.\n\n💡 Tip: Drink ORS and rest.";
    }

    else if (msg.contains("chest pain") || msg.contains("breathing")) {
      reply =
      "❤️ Chest pain may be serious.\n\nIf combined with:\n✔ Sweating\n✔ Left arm pain\n✔ Breathlessness\n\n➡️ Seek urgent care.\n\n👨‍⚕️ Specialist: **Cardiologist**.";
    }

    else if (msg.contains("skin") || msg.contains("rash") || msg.contains("itching")) {
      reply =
      "🧴 Skin symptoms detected.\nMay be allergy or infection.\n\n👨‍⚕️ Specialist: **Dermatologist**.";
    }

    else if (msg.contains("stomach") || msg.contains("gas") || msg.contains("abdominal")) {
      reply =
      "🍽️ Stomach pain detected.\nPossible gastritis or infection.\n\n👨‍⚕️ Specialist: **Gastroenterologist**.\n\n💡 Avoid oily/spicy food.";
    }

    else if (msg.contains("diabetes") || msg.contains("sugar")) {
      reply =
      "🩸 Diabetes care.\n\n👨‍⚕️ Specialist: **Endocrinologist**.\n\n💡 Avoid sugar & walk daily.";
    }

    else if (msg.contains("cough") || msg.contains("cold")) {
      reply =
      "🤧 Cough/Cold symptoms.\nMay be viral infection.\n\n👨‍⚕️ Doctor: **General Physician**.\n\n💡 Steam inhalation + warm water helps.";
    }

    else if (msg.contains("eye pain") || msg.contains("blur")) {
      reply =
      "👁 Eye discomfort detected.\nMay be allergy or screen strain.\n\n👨‍⚕️ Specialist: **Ophthalmologist**.";
    }

    // ---------- IF MESSAGE DOESN'T MATCH ANYTHING ----------
    else {
      reply =
      "🤔 I’m not fully sure about that.\nTry telling me a symptom like:\n• *I have fever*\n• *My back hurts*\n• *My eyes are itching*";
    }

    // ---------- ADDING REPLY TO CHAT ----------
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        _messages.add(_ChatMessage(text: reply, isUser: false));
      });
      _scrollToBottom();
    });
  }


  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 250), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }
  @override
  void initState() {
    super.initState();

    if (widget.selectedTopic != null && widget.selectedTopic!.isNotEmpty) {
      Future.delayed(Duration(milliseconds: 600), () {
        _messages.add(
          _ChatMessage(
            text: "Okay 👍 you selected **${widget.selectedTopic}**.\n\nLet me help...",
            isUser: false,
          ),
        );
        _scrollToBottom();
        _autoExplain(widget.selectedTopic!);
      });
    }
  }
  void _autoExplain(String topic) {
    String t = topic.toLowerCase().trim();
    String response = "";

    switch (t) {

      case "laparoscopy":
        response =
        "🔍 **Laparoscopy (Keyhole Surgery)**\n\n"
            "Laparoscopy ek minimally invasive surgery hoti hai jisme chhote incision se camera insert kiya jata hai.\n\n"
            "**Mostly used for:**\n"
            "• Gallbladder stone removal\n"
            "• Appendix surgery\n"
            "• Hernia repair\n"
            "• Fibroids / Ovarian cysts\n\n"
            "👨‍⚕️ Doctor Type: **Laparoscopic Surgeon**.\n\n"
            "💡 Patients choose laparoscopy because:\n"
            "✓ Less pain\n"
            "✓ Faster healing\n"
            "✓ Very small scars";
        break;


      case "gynaecology":
        response =
        "👩‍⚕️ **Gynaecology (Women's Health)**\n\n"
            "Gynaecology women’s reproductive system se related issues handle karti hai.\n\n"
            "**Common Reasons to visit:**\n"
            "• Irregular periods\n"
            "• PCOS / hormonal imbalance\n"
            "• Pregnancy checkup\n"
            "• Fibroids / cyst\n"
            "• Infection or discharge issues\n\n"
            "👩 Specialist: **Gynaecologist**.\n\n"
            "💡 Pro tip: If you experience pain with periods, heavy bleeding or fertility issues—get a consultation.";
        break;


      case "ent":
        response =
        "👂 **ENT (Ear, Nose, Throat)**\n\n"
            "ENT doctors treat ear infection, sinus, tonsils, throat infection aur voice problems.\n\n"
            "**Common symptoms:**\n"
            "• Ear pain / hearing issue\n"
            "• Sinus / blocked nose\n"
            "• Tonsils infection\n\n"
            "👨‍⚕️ Specialist: **ENT Surgeon (Otolaryngologist)**.";
        break;


      case "urology":
        response =
        "🚻 **Urology (Kidney & Urinary System)**\n\n"
            "Urology kidney, urinary bladder aur male reproductive system ke problems treat karta hai.\n\n"
            "**Common symptoms:**\n"
            "• Burning while urinating\n"
            "• Kidney stones\n"
            "• Frequent urination\n"
            "• Prostate problems (men)\n\n"
            "👨‍⚕️ Specialist: **Urologist**.";
        break;


      case "vascular":
        response =
        "🩸 **Vascular Surgery (Veins & Arteries)**\n\n"
            "Vascular specialist blood vessels se related issues handle karta hai.\n\n"
            "**Visit if you have:**\n"
            "• Varicose veins\n"
            "• Leg swelling & pain\n"
            "• Poor blood circulation\n"
            "• Diabetic foot wounds\n\n"
            "👨‍⚕️ Specialist: **Vascular Surgeon**.";
        break;


      case "aesthetics":
        response =
        "✨ **Aesthetics (Cosmetic Enhancements)**\n\n"
            "This includes cosmetic skin, face, body enhancement procedures.\n\n"
            "**Popular Treatments:**\n"
            "• Botox / fillers\n"
            "• Hair restoration / PRP\n"
            "• Chemical peels\n"
            "• Laser skin treatment\n\n"
            "👨‍⚕️ Specialist: **Cosmetic Dermatologist / Plastic Surgeon**.";
        break;


      case "orthopedics":
        response =
        "🦴 **Orthopedics (Bones & Joints)**\n\n"
            "Orthopedics doctors bone, joint aur muscular pain treat karte hain.\n\n"
            "**Common conditions:**\n"
            "• Knee pain / arthritis\n"
            "• Back or neck pain\n"
            "• Fractures\n"
            "• Sports injury\n\n"
            "👨‍⚕️ Specialist: **Orthopedic Surgeon / Physiotherapist**.";
        break;


      case "ophthalmology":
        response =
        "👁 **Ophthalmology (Eye Care)**\n\n"
            "Eye specialist vision issues aur eye infections treat karte hain.\n\n"
            "**Common reasons to visit:**\n"
            "• Blurry vision\n"
            "• Red eye / irritation\n"
            "• Cataract\n"
            "• Dry eyes\n\n"
            "👨‍⚕️ Specialist: **Ophthalmologist (Eye Surgeon)**.";
        break;


      case "account":
        response =
        "🧾 ‘Account’ section me aap apne profile, appointment history, reports aur saved prescriptions manage kar sakte ho.";
        break;


      default:
        response =
        "👍 Okay — Tell me what symptoms you experience related to **$topic** so I can guide you better.";
    }

    Future.delayed(Duration(milliseconds: 600), () {
      setState(() {
        _messages.add(_ChatMessage(text: response, isUser: false));
      });
      _scrollToBottom();
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          padding: const EdgeInsets.only(left: 20),
        ),
        backgroundColor: kTeal,
        title: const Text("Care AI Assistant", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [

          // 🔥 Quick Suggestion Buttons
          Container(
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: quickSymptoms.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                return GestureDetector(
                  onTap: () => _sendMessage(quickSymptoms[i]),
                  child: Chip(
                    label: Text(quickSymptoms[i],
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    backgroundColor: Colors.teal.shade50,
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: msg.isUser ? kTeal : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                          color: msg.isUser ? Colors.white : Colors.black87,
                          fontSize: 15),
                    ),
                  ),
                );
              },
            ),
          ),

          // 🔥 Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _sendMessage,
                    decoration: InputDecoration(
                      hintText: "Describe your symptoms...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                CircleAvatar(
                  backgroundColor: kTeal,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => _sendMessage(_controller.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}
