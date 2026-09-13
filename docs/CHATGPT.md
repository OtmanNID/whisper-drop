# Optional ChatGPT summaries with macOS Shortcuts

WhisperDrop can launch a macOS Shortcut after a transcript is created.

This is optional. The transcription-only mode remains completely local.

## 1. Enable ChatGPT in Apple Intelligence

On a compatible Mac:

1. Open **System Settings**.
2. Go to **Apple Intelligence & Siri**.
3. Configure the **ChatGPT** extension and sign in if desired.

## 2. Create the Shortcut

Create a Shortcut named:

```text
Résumer vocal avec ChatGPT
```

Set it to accept **Files** as input.

A working flow is:

1. **Get Text from Shortcut Input**
2. **Text** action containing your prompt and the extracted transcription
3. **Use Model → ChatGPT**
4. **Text** action containing the ChatGPT response
5. Build an output filename based on the input filename, for example:
   `Original name - résumé.txt`
6. **Set Name**
7. **Save File** to the same folder used by WhisperDrop

Suggested prompt:

```text
Résume cette transcription d'un vocal en français.

Donne uniquement les sections pertinentes parmi :
- Sujet principal
- Résumé
- Points importants
- Actions à faire
- Dates / échéances
- Montants / chiffres
- Personnes mentionnées
- Réponse suggérée

Sois fidèle au contenu. N'invente aucune information.

TRANSCRIPTION :
[Texte de la transcription]
```

## 3. Enable the provider

Edit:

```text
~/.config/whisperdrop/config
```

and set:

```bash
SUMMARY_PROVIDER="shortcuts"
SHORTCUT_NAME="Résumer vocal avec ChatGPT"
```

Then run:

```bash
whisperdrop doctor
```

You should see the Shortcut reported as available.

## Test manually

```bash
shortcuts run "Résumer vocal avec ChatGPT" -i "$HOME/Documents/WhatsApp Audios/example.txt"
```

If this works, WhisperDrop will be able to invoke it automatically after transcription.
