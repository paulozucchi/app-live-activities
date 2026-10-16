import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Instância única (Singleton) para garantir que o plugin seja inicializado apenas uma vez
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inicializa o plugin de notificações e configura as permissões
  Future<void> initNotification() async {
    // Configurações para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configurações para iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // CORREÇÃO LINHA 32 e 33: Agora usa o parâmetro nomeado 'settings:'
    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("Notificação clicada com payload: ${response.payload}");
      },
    );

    // Solicita permissões explicitamente (Android 13+)
    await requestPermissions();
  }

  /// Solicita permissões de notificação para Android 13+ e iOS
  Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  /// 1. DISPARAR NOTIFICAÇÃO CUSTOMIZADA (Fundo colorido + Suporte a HTML)
  Future<void> showBrandNotification({
    required int id,
    required String title,
    required String bodyHtml,
    String? payload,
  }) async {
    const Color brandPink = Color(0xFFFF1493); 

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'brand_channel_id',
      'Notificações da Marca',
      channelDescription: 'Canal personalizado com a identidade visual da empresa',
      importance: Importance.max,
      priority: Priority.high,
      color: brandPink,
      colorized: true,
      styleInformation: const BigTextStyleInformation(
        '', 
        htmlFormatContent: true, 
        htmlFormatTitle: true,   
      ),
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    // CORREÇÃO LINHA 85: Passando todos os parâmetros nomeados explicitamente
    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: bodyHtml,
      notificationDetails: platformDetails,
      payload: payload,
    );
  }

  /// 2. DISPARAR NOTIFICAÇÃO COM CRONÔMETRO (Contagem Regressiva)
  Future<void> showTimerNotification({
    required int id,
    required String title,
    required String body,
    required Duration duration,
  }) async {
    final int targetTimestamp = DateTime.now().add(duration).millisecondsSinceEpoch;

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'timer_channel_id',
      'Cronômetro de Tarefas',
      channelDescription: 'Notificações que mostram uma contagem regressiva ativa',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true, 
      when: targetTimestamp, 
      usesChronometer: true, 
      chronometerCountDown: true, 
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    // CORREÇÃO LINHA 120: Passando todos os parâmetros nomeados explicitamente
    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformDetails,
    );
  }
}