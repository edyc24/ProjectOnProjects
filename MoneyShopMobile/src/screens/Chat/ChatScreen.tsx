import React, {useState, useEffect, useRef} from 'react';
import {
  View,
  StyleSheet,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
  TextInput,
} from 'react-native';
import {Text, Button, Card, Snackbar} from 'react-native-paper';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import {chatApi, ChatRequest, ChatResponse} from '../../services/api/chatApi';

interface Message {
  id: string;
  text: string;
  isUser: boolean;
  timestamp: Date;
}

const ChatScreen: React.FC = () => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [inputText, setInputText] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [showError, setShowError] = useState(false);
  const scrollViewRef = useRef<ScrollView>(null);

  useEffect(() => {
    loadInitialMessage();
  }, []);

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const loadInitialMessage = async () => {
    try {
      const response = await chatApi.getInitialMessage();
      setMessages([
        {
          id: 'initial',
          text: response.mesaj,
          isUser: false,
          timestamp: new Date(),
        },
      ]);
    } catch (err: any) {
      setError('Nu s-a putut incarca mesajul initial');
      setShowError(true);
    }
  };

  const scrollToBottom = () => {
    setTimeout(() => {
      scrollViewRef.current?.scrollToEnd({animated: true});
    }, 100);
  };

  const handleSend = async () => {
    if (!inputText.trim() || loading) return;

    const userMessage: Message = {
      id: Date.now().toString(),
      text: inputText.trim(),
      isUser: true,
      timestamp: new Date(),
    };

    setMessages(prev => [...prev, userMessage]);
    setInputText('');
    setLoading(true);
    setError(null);

    try {
      const request: ChatRequest = {
        message: userMessage.text,
        conversation_id: 'default',
      };

      const response: ChatResponse = await chatApi.sendMessage(request);

      const botMessage: Message = {
        id: (Date.now() + 1).toString(),
        text: response.raspuns,
        isUser: false,
        timestamp: new Date(),
      };

      setMessages(prev => [...prev, botMessage]);
    } catch (err: any) {
      const errorMessage =
        err.response?.data?.error === 'prea_multe_cereri'
          ? 'Ai depasit limita de mesaje. Te rugam sa astepti.'
          : err.response?.data?.error === 'buget_depasit'
          ? 'Bugetul lunar a fost depasit. Te rugam sa incerci mai tarziu.'
          : 'Eroare la trimiterea mesajului. Te rugam sa incerci din nou.';

      setError(errorMessage);
      setShowError(true);
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      keyboardVerticalOffset={Platform.OS === 'ios' ? 90 : 0}>
      <View style={styles.header}>
        <Icon name="robot" size={24} color="#1976D2" />
        <Text variant="titleLarge" style={styles.headerTitle}>
          Asistent Virtual
        </Text>
      </View>

      <ScrollView
        ref={scrollViewRef}
        style={styles.messagesContainer}
        contentContainerStyle={styles.messagesContent}>
        {messages.map(msg => (
          <View
            key={msg.id}
            style={[
              styles.messageWrapper,
              msg.isUser ? styles.userMessageWrapper : styles.botMessageWrapper,
            ]}>
            <Card
              style={[
                styles.messageCard,
                msg.isUser ? styles.userMessageCard : styles.botMessageCard,
              ]}>
              <Card.Content style={styles.messageContent}>
                <Text
                  variant="bodyMedium"
                  style={[
                    styles.messageText,
                    msg.isUser ? styles.userMessageText : styles.botMessageText,
                  ]}>
                  {msg.text}
                </Text>
                {!msg.isUser && msg.id === 'initial' && (
                  <View style={styles.disclaimerContainer}>
                    <Text variant="bodySmall" style={styles.disclaimerText}>
                      Disclaimer: Asistentul virtual ofera informatii generale si
                      explicatii educationale. Nu reprezinta consultanta financiara
                      personalizata.
                    </Text>
                  </View>
                )}
              </Card.Content>
            </Card>
          </View>
        ))}
        {loading && (
          <View style={styles.botMessageWrapper}>
            <Card style={styles.botMessageCard}>
              <Card.Content style={styles.messageContent}>
                <Text variant="bodyMedium" style={styles.botMessageText}>
                  Se proceseaza...
                </Text>
              </Card.Content>
            </Card>
          </View>
        )}
      </ScrollView>

      <View style={styles.inputContainer}>
        <TextInput
          style={styles.input}
          value={inputText}
          onChangeText={setInputText}
          placeholder="Scrie mesajul tau..."
          placeholderTextColor="#B0B0B0"
          multiline
          maxLength={2000}
          editable={!loading}
        />
        <Button
          mode="contained"
          onPress={handleSend}
          disabled={!inputText.trim() || loading}
          style={styles.sendButton}
          icon="send">
          Trimite
        </Button>
      </View>

      <Snackbar
        visible={showError}
        onDismiss={() => setShowError(false)}
        duration={4000}
        style={styles.snackbar}>
        {error || 'Eroare'}
      </Snackbar>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    backgroundColor: '#FFFFFF',
    borderBottomWidth: 1,
    borderBottomColor: '#E0E0E0',
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 2},
    shadowOpacity: 0.05,
    shadowRadius: 4,
  },
  headerTitle: {
    marginLeft: 12,
    color: '#212121',
    fontWeight: '700',
  },
  messagesContainer: {
    flex: 1,
  },
  messagesContent: {
    padding: 16,
    paddingBottom: 20,
  },
  messageWrapper: {
    marginBottom: 12,
  },
  userMessageWrapper: {
    alignItems: 'flex-end',
  },
  botMessageWrapper: {
    alignItems: 'flex-start',
  },
  messageCard: {
    maxWidth: '80%',
    borderRadius: 16,
  },
  userMessageCard: {
    backgroundColor: '#1976D2',
  },
  botMessageCard: {
    backgroundColor: '#F5F5F5',
  },
  messageContent: {
    padding: 12,
  },
  messageText: {
    color: '#212121',
    lineHeight: 20,
  },
  userMessageText: {
    color: '#FFFFFF',
  },
  botMessageText: {
    color: '#212121',
  },
  disclaimerContainer: {
    marginTop: 12,
    padding: 10,
    backgroundColor: '#FFF3E0',
    borderRadius: 8,
    borderLeftWidth: 3,
    borderLeftColor: '#FF9800',
  },
  disclaimerText: {
    color: '#757575',
    fontSize: 11,
    lineHeight: 16,
  },
  inputContainer: {
    flexDirection: 'row',
    padding: 16,
    backgroundColor: '#FFFFFF',
    borderTopWidth: 1,
    borderTopColor: '#E0E0E0',
    alignItems: 'flex-end',
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: -2},
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  input: {
    flex: 1,
    backgroundColor: '#F5F5F5',
    borderRadius: 20,
    paddingHorizontal: 16,
    paddingVertical: 12,
    color: '#212121',
    maxHeight: 100,
    marginRight: 12,
    fontSize: 16,
    borderWidth: 1,
    borderColor: '#E0E0E0',
  },
  sendButton: {
    backgroundColor: '#1976D2',
    borderRadius: 20,
    elevation: 2,
    shadowColor: '#1976D2',
    shadowOffset: {width: 0, height: 2},
    shadowOpacity: 0.2,
    shadowRadius: 4,
  },
  snackbar: {
    backgroundColor: '#F44336',
  },
});

export default ChatScreen;

