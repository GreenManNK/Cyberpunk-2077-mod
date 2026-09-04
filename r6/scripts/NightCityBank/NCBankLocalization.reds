module NightCityBank

public class NCBankLocalization {
  public static func Get(language: NCBankLanguage, key: CName) -> String {
    if Equals(language, NCBankLanguage.ChineseSimplified) || Equals(language, NCBankLanguage.ChineseTraditional) { return NCBankLocalization.Get_zh_cn(key); };
    if Equals(language, NCBankLanguage.German) { return NCBankLocalization.Get_de_de(key); };
    if Equals(language, NCBankLanguage.Spanish) || Equals(language, NCBankLanguage.SpanishMexico) { return NCBankLocalization.Get_es_es(key); };
    if Equals(language, NCBankLanguage.French) { return NCBankLocalization.Get_fr_fr(key); };
    if Equals(language, NCBankLanguage.Japanese) { return NCBankLocalization.Get_ja_jp(key); };
    if Equals(language, NCBankLanguage.Korean) { return NCBankLocalization.Get_ko_kr(key); };
    if Equals(language, NCBankLanguage.Polish) { return NCBankLocalization.Get_pl_pl(key); };
    if Equals(language, NCBankLanguage.Portuguese) { return NCBankLocalization.Get_pt_br(key); };
    if Equals(language, NCBankLanguage.Russian) { return NCBankLocalization.Get_ru_ru(key); };
    if Equals(language, NCBankLanguage.Turkish) { return NCBankLocalization.Get_tr_tr(key); };
    if Equals(language, NCBankLanguage.Vietnamese) { return NCBankLocalization.Get_vi_vn(key); };
    return NCBankLocalization.Get_en_us(key);
  }

  public static func Get_en_us(key: CName) -> String {
    if Equals(key, n"mb_loc_001") { return "Marmur Bank account notice posted. Confirmation No. "; };
    if Equals(key, n"mb_loc_002") { return "Marmur Bank — transaction confirmations."; };
    if Equals(key, n"mb_loc_003") { return "Marmur Bank security alert — a purchase of "; };
    if Equals(key, n"mb_loc_004") { return "Security check pending. Please confirm whether the latest high-value purchase was authorized."; };
    if Equals(key, n"mb_loc_005") { return "No, I did not authorize this purchase"; };
    if Equals(key, n"mb_loc_006") { return "Marmur Bank account services are unavailable right now."; };
    if Equals(key, n"mb_loc_007") { return "Account summary:"; };
    if Equals(key, n"mb_loc_008") { return "Marmur Bank savings notice — account yield of "; };
    if Equals(key, n"mb_loc_009") { return ". Tax withheld: "; };
    if Equals(key, n"mb_loc_010") { return ". Did you authorize this purchase? Alert ID "; };
    if Equals(key, n"mb_loc_011") { return ". Savings: "; };
    if Equals(key, n"mb_loc_012") { return "Marmur Bank loan notice — scheduled payment of "; };
    if Equals(key, n"mb_loc_013") { return "Marmur Bank account notice — Checking monthly fee of "; };
    if Equals(key, n"mb_loc_014") { return "Marmur Bank private client services — account custody and monitoring fee of "; };
    if Equals(key, n"mb_loc_015") { return "Marmur Bank dispute opened — spending transaction review requested for "; };
    return "";
  }

  public static func Get_zh_cn(key: CName) -> String {
    if Equals(key, n"mb_loc_001") { return "马尔穆尔银行账户通知已发布。确认编号 "; };
    if Equals(key, n"mb_loc_002") { return "马尔穆尔银行 — 交易确认。"; };
    if Equals(key, n"mb_loc_003") { return "马尔穆尔银行安全警报 — 消费金额 "; };
    if Equals(key, n"mb_loc_004") { return "安全检查待处理。请确认最近一笔高额消费是否已授权。"; };
    if Equals(key, n"mb_loc_005") { return "否，我没有授权这笔消费"; };
    if Equals(key, n"mb_loc_006") { return "马尔穆尔银行账户服务当前不可用。"; };
    if Equals(key, n"mb_loc_007") { return "账户摘要："; };
    if Equals(key, n"mb_loc_008") { return "马尔穆尔银行储蓄通知 — 账户收益 "; };
    if Equals(key, n"mb_loc_009") { return ". 预扣税："; };
    if Equals(key, n"mb_loc_010") { return ". 你是否授权了这笔消费？警报 ID "; };
    if Equals(key, n"mb_loc_011") { return ". 储蓄："; };
    if Equals(key, n"mb_loc_012") { return "马尔穆尔银行贷款通知 — 计划还款 "; };
    if Equals(key, n"mb_loc_013") { return "马尔穆尔银行账户通知 — 支票账户月费 "; };
    if Equals(key, n"mb_loc_014") { return "马尔穆尔银行私人客户服务 — 账户托管与监控费用 "; };
    if Equals(key, n"mb_loc_015") { return "马尔穆尔银行争议已开启 — 支出交易审核金额 "; };
    return NCBankLocalization.Get_en_us(key);
  }

  public static func Get_de_de(key: CName) -> String {
    if Equals(key, n"mb_loc_002") { return "Marmur Bank — Transaktionsbestätigungen."; };
    if Equals(key, n"mb_loc_003") { return "Marmur-Bank-Sicherheitsalarm — ein Kauf über "; };
    if Equals(key, n"mb_loc_004") { return "Sicherheitsprüfung ausstehend. Bitte bestätige, ob der letzte hochpreisige Kauf autorisiert war."; };
    if Equals(key, n"mb_loc_005") { return "Nein, ich habe diesen Kauf nicht autorisiert"; };
    if Equals(key, n"mb_loc_006") { return "Marmur-Bank-Kontodienste sind derzeit nicht verfügbar."; };
    if Equals(key, n"mb_loc_007") { return "Kontozusammenfassung:"; };
    if Equals(key, n"mb_loc_008") { return "Marmur-Bank-Sparmitteilung — Kontorendite von "; };
    if Equals(key, n"mb_loc_009") { return ". Einbehaltene Steuer: "; };
    if Equals(key, n"mb_loc_010") { return ". Hast du diesen Kauf autorisiert? Alarm-ID "; };
    if Equals(key, n"mb_loc_011") { return ". Ersparnisse: "; };
    if Equals(key, n"mb_loc_012") { return "Marmur-Bank-Kreditmitteilung — geplante Zahlung über "; };
    if Equals(key, n"mb_loc_013") { return "Marmur-Bank-Kontomitteilung — monatliche Girogebühr über "; };
    if Equals(key, n"mb_loc_014") { return "Marmur-Bank Private Client Services — Konto-Verwahrungs- und Überwachungsgebühr über "; };
    if Equals(key, n"mb_loc_015") { return "Marmur-Bank-Streitfall eröffnet — Prüfung der Ausgabe angefordert über "; };
    return NCBankLocalization.Get_en_us(key);
  }

  public static func Get_es_es(key: CName) -> String {
    if Equals(key, n"mb_loc_002") { return "Marmur Bank — confirmaciones de transacción."; };
    if Equals(key, n"mb_loc_003") { return "Alerta de seguridad de Marmur Bank — una compra de "; };
    if Equals(key, n"mb_loc_004") { return "Control de seguridad pendiente. Confirma si la última compra de alto valor fue autorizada."; };
    if Equals(key, n"mb_loc_005") { return "No, no autoricé esta compra"; };
    if Equals(key, n"mb_loc_006") { return "Los servicios de cuenta Marmur Bank no están disponibles ahora."; };
    if Equals(key, n"mb_loc_007") { return "Resumen de cuenta:"; };
    if Equals(key, n"mb_loc_008") { return "Aviso de ahorro de Marmur Bank — rendimiento de cuenta de "; };
    if Equals(key, n"mb_loc_009") { return ". Impuesto retenido: "; };
    if Equals(key, n"mb_loc_010") { return ". ¿Autorizaste esta compra? ID de alerta "; };
    if Equals(key, n"mb_loc_011") { return ". Ahorros: "; };
    if Equals(key, n"mb_loc_012") { return "Aviso de préstamo Marmur Bank — pago programado de "; };
    if Equals(key, n"mb_loc_013") { return "Aviso de cuenta Marmur Bank — comisión mensual de corriente de "; };
    if Equals(key, n"mb_loc_014") { return "Servicios de cliente privado Marmur Bank — comisión de custodia y monitoreo de cuenta de "; };
    if Equals(key, n"mb_loc_015") { return "Disputa Marmur Bank abierta — revisión de gasto solicitada por "; };
    return NCBankLocalization.Get_en_us(key);
  }

  public static func Get_fr_fr(key: CName) -> String {
    if Equals(key, n"mb_loc_002") { return "Marmur Bank — confirmations de transaction."; };
    if Equals(key, n"mb_loc_003") { return "Alerte sécurité Marmur Bank — un achat de "; };
    if Equals(key, n"mb_loc_004") { return "Vérification de sécurité en attente. Confirmez si le dernier achat de valeur était autorisé."; };
    if Equals(key, n"mb_loc_005") { return "Non, je n’ai pas autorisé cet achat"; };
    if Equals(key, n"mb_loc_006") { return "Les services de compte Marmur Bank sont indisponibles pour l’instant."; };
    if Equals(key, n"mb_loc_007") { return "Résumé du compte :"; };
    if Equals(key, n"mb_loc_008") { return "Avis d’épargne Marmur Bank — rendement de compte de "; };
    if Equals(key, n"mb_loc_009") { return ". Taxe retenue : "; };
    if Equals(key, n"mb_loc_010") { return ". Avez-vous autorisé cet achat ? ID d’alerte "; };
    if Equals(key, n"mb_loc_011") { return ". Épargne : "; };
    if Equals(key, n"mb_loc_012") { return "Avis de prêt Marmur Bank — paiement prévu de "; };
    if Equals(key, n"mb_loc_013") { return "Avis de compte Marmur Bank — frais mensuels courant de "; };
    if Equals(key, n"mb_loc_014") { return "Services client privé Marmur Bank — frais de garde et surveillance de compte de "; };
    if Equals(key, n"mb_loc_015") { return "Litige Marmur Bank ouvert — examen de dépense demandé pour "; };
    return NCBankLocalization.Get_en_us(key);
  }

  public static func Get_ja_jp(key: CName) -> String {
    if Equals(key, n"mb_loc_001") { return "Marmur Bank口座通知。確認番号 "; };
    if Equals(key, n"mb_loc_002") { return "Marmur Bank — 取引確認。"; };
    if Equals(key, n"mb_loc_003") { return "Marmur Bankセキュリティ警告 — 購入額 "; };
    if Equals(key, n"mb_loc_004") { return "セキュリティ確認待ちです。直近の高額購入を承認したか確認してください。"; };
    if Equals(key, n"mb_loc_005") { return "いいえ、この購入は承認していません"; };
    if Equals(key, n"mb_loc_006") { return "Marmur Bank口座サービスは現在利用できません。"; };
    if Equals(key, n"mb_loc_007") { return "口座概要："; };
    if Equals(key, n"mb_loc_008") { return "Marmur Bank貯蓄通知 — 口座利回り "; };
    if Equals(key, n"mb_loc_009") { return "。源泉徴収税："; };
    if Equals(key, n"mb_loc_010") { return "。この購入を承認しましたか？アラートID "; };
    if Equals(key, n"mb_loc_011") { return "。貯蓄："; };
    if Equals(key, n"mb_loc_012") { return "Marmur Bankローン通知 — 予定支払額 "; };
    if Equals(key, n"mb_loc_013") { return "Marmur Bank口座通知 — 当座預金月額手数料 "; };
    if Equals(key, n"mb_loc_014") { return "Marmur Bankプライベートクライアントサービス — 口座保管・監視手数料 "; };
    if Equals(key, n"mb_loc_015") { return "Marmur Bank異議申立を受理 — 支出取引の審査請求額 "; };
    return NCBankLocalization.Get_en_us(key);
  }

  public static func Get_ko_kr(key: CName) -> String {
    if Equals(key, n"mb_loc_002") { return "마르무르 은행 — 거래 확인."; };
    if Equals(key, n"mb_loc_003") { return "마르무르 은행 보안 경고 — 구매 금액 "; };
    if Equals(key, n"mb_loc_004") { return "보안 확인 대기 중. 최근 고액 구매 승인 여부를 확인하세요."; };
    if Equals(key, n"mb_loc_005") { return "아니요, 승인하지 않았습니다"; };
    if Equals(key, n"mb_loc_006") { return "현재 마르무르 은행 계좌 서비스를 사용할 수 없습니다."; };
    if Equals(key, n"mb_loc_007") { return "계좌 요약:"; };
    if Equals(key, n"mb_loc_008") { return "마르무르 은행 저축 알림 — 계좌 수익 "; };
    if Equals(key, n"mb_loc_009") { return ". 원천징수세: "; };
    if Equals(key, n"mb_loc_010") { return ". 이 구매를 승인하셨나요? 경고 ID "; };
    if Equals(key, n"mb_loc_011") { return ". 저축: "; };
    if Equals(key, n"mb_loc_012") { return "마르무르 은행 대출 알림 — 예정 상환액 "; };
    if Equals(key, n"mb_loc_013") { return "마르무르 은행 계좌 알림 — 당좌 월 수수료 "; };
    if Equals(key, n"mb_loc_014") { return "마르무르 은행 프라이빗 고객 서비스 — 계좌 보관 및 모니터링 수수료 "; };
    if Equals(key, n"mb_loc_015") { return "마르무르 은행 분쟁 접수 — 지출 거래 검토 요청액 "; };
    return NCBankLocalization.Get_en_us(key);
  }

  public static func Get_pl_pl(key: CName) -> String {
    if Equals(key, n"mb_loc_002") { return "Bank Marmur — potwierdzenia transakcji."; };
    if Equals(key, n"mb_loc_003") { return "Alert bezpieczeństwa Banku Marmur — zakup za "; };
    if Equals(key, n"mb_loc_004") { return "Oczekuje kontrola bezpieczeństwa. Potwierdź autoryzację ostatniego dużego zakupu."; };
    if Equals(key, n"mb_loc_005") { return "Nie, nie autoryzuję tego zakupu"; };
    if Equals(key, n"mb_loc_006") { return "Usługi konta Banku Marmur są teraz niedostępne."; };
    if Equals(key, n"mb_loc_007") { return "Podsumowanie konta:"; };
    if Equals(key, n"mb_loc_008") { return "Powiadomienie Banku Marmur — zysk z konta "; };
    if Equals(key, n"mb_loc_009") { return ". Potrącony podatek: "; };
    if Equals(key, n"mb_loc_010") { return ". Czy autoryzowano ten zakup? ID alertu "; };
    if Equals(key, n"mb_loc_011") { return ". Oszczędności: "; };
    if Equals(key, n"mb_loc_012") { return "Powiadomienie Banku Marmur o pożyczce — zaplanowana płatność "; };
    if Equals(key, n"mb_loc_013") { return "Powiadomienie Banku Marmur — miesięczna opłata bieżąca "; };
    if Equals(key, n"mb_loc_014") { return "Usługi klienta prywatnego Banku Marmur — opłata za depozyt i monitoring konta "; };
    if Equals(key, n"mb_loc_015") { return "Spór Banku Marmur otwarty — przegląd transakcji wydatku na "; };
    return NCBankLocalization.Get_en_us(key);
  }

  public static func Get_pt_br(key: CName) -> String {
    if Equals(key, n"mb_loc_002") { return "Banco Marmur — confirmações de transação."; };
    if Equals(key, n"mb_loc_003") { return "Alerta de segurança do Banco Marmur — uma compra de "; };
    if Equals(key, n"mb_loc_004") { return "Verificação de segurança pendente. Confirme se a última compra de alto valor foi autorizada."; };
    if Equals(key, n"mb_loc_005") { return "Não, não autorizei esta compra"; };
    if Equals(key, n"mb_loc_006") { return "Serviços da conta Marmur Bank indisponíveis agora."; };
    if Equals(key, n"mb_loc_007") { return "Resumo da conta:"; };
    if Equals(key, n"mb_loc_008") { return "Aviso de poupança do Banco Marmur — rendimento da conta de "; };
    if Equals(key, n"mb_loc_009") { return ". Imposto retido: "; };
    if Equals(key, n"mb_loc_010") { return ". Você autorizou esta compra? ID do alerta "; };
    if Equals(key, n"mb_loc_011") { return ". Poupança: "; };
    if Equals(key, n"mb_loc_012") { return "Aviso de empréstimo Banco Marmur — pagamento agendado de "; };
    if Equals(key, n"mb_loc_013") { return "Aviso de conta Banco Marmur — taxa mensal da conta corrente de "; };
    if Equals(key, n"mb_loc_014") { return "Serviços de cliente privado Banco Marmur — taxa de custódia e monitoramento de conta de "; };
    if Equals(key, n"mb_loc_015") { return "Disputa Banco Marmur aberta — revisão de gasto solicitada de "; };
    return NCBankLocalization.Get_en_us(key);
  }

  public static func Get_ru_ru(key: CName) -> String {
    if Equals(key, n"mb_loc_002") { return "Банк Marmur — подтверждения операций."; };
    if Equals(key, n"mb_loc_003") { return "Предупреждение безопасности банка Marmur — покупка на "; };
    if Equals(key, n"mb_loc_004") { return "Ожидается проверка безопасности. Подтвердите, была ли авторизована последняя крупная покупка."; };
    if Equals(key, n"mb_loc_005") { return "Нет, я не авторизовал эту покупку"; };
    if Equals(key, n"mb_loc_006") { return "Услуги счёта Marmur Bank сейчас недоступны."; };
    if Equals(key, n"mb_loc_007") { return "Сводка счёта:"; };
    if Equals(key, n"mb_loc_008") { return "Уведомление банка Marmur — доходность счёта "; };
    if Equals(key, n"mb_loc_009") { return ". Удержан налог: "; };
    if Equals(key, n"mb_loc_010") { return ". Вы авторизовали эту покупку? ID предупреждения "; };
    if Equals(key, n"mb_loc_011") { return ". Сбережения: "; };
    if Equals(key, n"mb_loc_012") { return "Уведомление банка Marmur о кредите — плановый платёж "; };
    if Equals(key, n"mb_loc_013") { return "Уведомление банка Marmur — ежемесячная плата расчётного счёта "; };
    if Equals(key, n"mb_loc_014") { return "Услуги частного клиента банка Marmur — плата за хранение и мониторинг счёта "; };
    if Equals(key, n"mb_loc_015") { return "Спор банка Marmur открыт — проверка расходной операции на "; };
    return NCBankLocalization.Get_en_us(key);
  }

  public static func Get_tr_tr(key: CName) -> String {
    if Equals(key, n"mb_loc_001") { return "Marmur Bank hesap bildirimi yayımlandı. Onay No. "; };
    if Equals(key, n"mb_loc_002") { return "Marmur Bank — işlem onayları."; };
    if Equals(key, n"mb_loc_003") { return "Marmur Bank güvenlik uyarısı — satın alma tutarı "; };
    if Equals(key, n"mb_loc_004") { return "Güvenlik kontrolü bekleniyor. Lütfen son yüksek tutarlı satın alma işleminin yetkili olup olmadığını onaylayın."; };
    if Equals(key, n"mb_loc_005") { return "Hayır, bu satın alma işlemine izin vermedim"; };
    if Equals(key, n"mb_loc_006") { return "Marmur Bank hesap hizmetleri şu anda kullanılamıyor."; };
    if Equals(key, n"mb_loc_007") { return "Hesap özeti:"; };
    if Equals(key, n"mb_loc_008") { return "Marmur Bank birikim bildirimi — hesap getirisi "; };
    if Equals(key, n"mb_loc_009") { return ". Kesilen vergi: "; };
    if Equals(key, n"mb_loc_010") { return ". Bu satın alma işlemine izin verdiniz mi? Uyarı Kimliği "; };
    if Equals(key, n"mb_loc_011") { return ". Birikim: "; };
    if Equals(key, n"mb_loc_012") { return "Marmur Bank kredi bildirimi — planlanan ödeme "; };
    if Equals(key, n"mb_loc_013") { return "Marmur Bank hesap bildirimi — vadesiz hesap aylık ücreti "; };
    if Equals(key, n"mb_loc_014") { return "Marmur Bank özel müşteri hizmetleri — hesap saklama ve izleme ücreti "; };
    if Equals(key, n"mb_loc_015") { return "Marmur Bank anlaşmazlığı açıldı — inceleme istenen harcama tutarı "; };
    return NCBankLocalization.Get_en_us(key);
  }

  public static func Get_vi_vn(key: CName) -> String {
    if Equals(key, n"mb_loc_001") { return "Thông báo tài khoản Marmur Bank đã được đăng. Số xác nhận "; };
    if Equals(key, n"mb_loc_002") { return "Marmur Bank — xác nhận giao dịch."; };
    if Equals(key, n"mb_loc_003") { return "Cảnh báo bảo mật Marmur Bank — giao dịch mua trị giá "; };
    if Equals(key, n"mb_loc_004") { return "Đang chờ kiểm tra bảo mật. Vui lòng xác nhận giao dịch mua giá trị cao gần nhất có được ủy quyền hay không."; };
    if Equals(key, n"mb_loc_005") { return "Không, tôi không cho phép giao dịch mua này"; };
    if Equals(key, n"mb_loc_006") { return "Dịch vụ tài khoản Marmur Bank hiện không khả dụng."; };
    if Equals(key, n"mb_loc_007") { return "Tóm tắt tài khoản:"; };
    if Equals(key, n"mb_loc_008") { return "Thông báo tiết kiệm Marmur Bank — lợi suất tài khoản "; };
    if Equals(key, n"mb_loc_009") { return ". Thuế đã khấu trừ: "; };
    if Equals(key, n"mb_loc_010") { return ". Bạn có cho phép giao dịch mua này không? ID cảnh báo "; };
    if Equals(key, n"mb_loc_011") { return ". Tiết kiệm: "; };
    if Equals(key, n"mb_loc_012") { return "Thông báo khoản vay Marmur Bank — khoản thanh toán theo lịch "; };
    if Equals(key, n"mb_loc_013") { return "Thông báo tài khoản Marmur Bank — phí tài khoản thanh toán hằng tháng "; };
    if Equals(key, n"mb_loc_014") { return "Dịch vụ khách hàng cao cấp Marmur Bank — phí lưu ký và giám sát tài khoản "; };
    if Equals(key, n"mb_loc_015") { return "Đã mở tranh chấp Marmur Bank — yêu cầu xem xét giá trị giao dịch chi tiêu "; };
    return NCBankLocalization.Get_en_us(key);
  }

}
