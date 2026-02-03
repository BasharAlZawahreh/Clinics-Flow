#!/bin/bash
# 🎯 Workflow: تحويل النص إلى صوت + إرسال إلى تيليغرام
# ElevenLabs Integration Service

set -e

# ==============
# إعدادات
# ==============

API_SERVICE_DIR="${HOME}/.openclaw/workspace/elevenlabs-service"
API_PORT=3003

# ElevenLabs API Key (ضعه من: https://elevenlabs.io/app)
# أو في .env
ELEVENLABS_API_KEY="${ELEVENLABS_API_KEY:-}"

# Telegram Bot Token
# احصل من @BotFather على تيليغرام
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"

# ==============
# الألوان
# ==============

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ==============
# دوال المساعدة
# ==============

show_help() {
    echo ""
    echo "${CYAN}═══════════════════════════════════════════${NC}"
    echo "${GREEN}🎤 Workflow: تحويل النص إلى صوت ${NC}"
    echo "${CYAN}═════════════════════════════════════════${NC}"
    echo ""
    echo "${BLUE}📋 الاستخدام:${NC}"
    echo "${CYAN}  ./workflow.sh \"[النص]\" ${NC}"
    echo "${CYAN}  ./workflow.sh start${NC}"
    echo "${CYAN}  ./workflow.sh test${NC}"
    echo ""
    echo "${GREEN}🚀 الأوامر:${NC}"
    echo "${YELLOW}  start    - تشغيل خدمة ElevenLabs API${NC}"
    echo "${YELLOW}  test     - اختبار الخدمة${NC}"
    echo "${YELLOW}  stop     - إيقاف الخدمة${NC}"
    echo "${YELLOW}  status   - حالة الخدمة${NC}"
    echo "${YELLOW}  logs     - سجلات الخدمة${NC}"
    echo "${YELLOW}  health   - فحص صحة API${NC}"
    echo ""
    echo "${BLUE}📁 دليل API:${NC}"
    echo "${CYAN}  Text to Speech:${NC}"
    echo "${CYAN}  ${API_URL}/api/text-to-speech - POST${NC}"
    echo "${CYAN}  GET /voices - قائمة الأصوات${NC}"
    echo "${CYAN}  GET /health - فحص الصحة${NC}"
    echo "${CYAN}  GET /stats - إحصائيات الاستخدام${NC}"
    echo ""
    echo "${GREEN}✨ مثال:${NC}"
    echo "${YELLOW}  curl -X POST http://localhost:${API_PORT}/api/text-to-speech \\${NC}"
    echo "${YELLOW}    -H \"Content-Type: application/json\" \\${NC}"
    echo "${YELLOW}    -d '{\"text\": \"مرحباً بك\"}'${NC}"
    echo ""
    echo "${CYAN}═════════════════════════════════════════${NC}"
}

# ==============
# التحقق من التبعيات
# ==============

check_dependencies() {
    echo "${BLUE}🔍 التحقق من الاعتماديات...${NC}"
    
    # التحقق من API service
    if [ ! -d "$API_SERVICE_DIR" ]; then
        echo "${RED}❌ خدمة ElevenLabs API غير موجودة${NC}"
        echo "${YELLOW}💡 هل نسخت المشروع؟${NC}"
        echo "${YELLOW}   git clone https://github.com/BasharAlZawahreh/Clinics-Flow.git${NC}"
        exit 1
    fi
    
    # التحقق من Node.js
    if ! command -v node &> /dev/null; then
        echo "${RED}❌ Node.js غير مثبت${NC}"
        echo "${YELLOW}💡 قم بتثبيته: apt install nodejs${NC}"
        exit 1
    fi
    
    echo "${GREEN}✅ جميع الاعتماديات جاهزة${NC}"
    echo ""
}

# ==============
# تشغيل خدمة API
# ==============

start_service() {
    echo "${BLUE}🚀 تشغيل خدمة ElevenLabs API...${NC}"
    echo ""
    
    cd "$API_SERVICE_DIR" 2>/dev/null || {
        echo "${RED}❌ المجل غير موجود${NC}"
        exit 1
    }
    
    # التحقق من API key
    if [ -z "$ELEVENLABS_API_KEY" ]; then
        echo "${YELLOW}⚠️  لم يتم تحديد ELEVENLABS_API_KEY${NC}"
        echo "${YELLOW}💡 استخدم المفتاح المجاني للتجربة${NC}"
        echo "${YELLOW}💡 للحصول على المفتاح: https://elevenlabs.io/app${NC}"
        echo ""
    fi
    
    # تشغيل الخدمة
    echo "${GREEN}✅ تشغيل الخدمة على المنفذ ${API_PORT}...${NC}"
    npm start > /tmp/elevenlabs-service.log 2>&1 &
    
    # حفظ PID
    echo $! > /tmp/elevenlabs-service.pid
    
    # الانتظار قليلاً
    echo "${YELLOW}⏳ انتظار تشغيل الخدمة...${NC}"
    sleep 5
    
    # التحقق من الخدمة
    if curl -s http://localhost:${API_PORT}/api/health > /dev/null; then
        echo "${GREEN}✅ الخدمة تعمل بنجاح!${NC}"
        echo "${GREEN}🌐 API: http://localhost:${API_PORT}${NC}"
        echo "${GREEN}📱 واجهة: http://localhost:${API_PORT}${NC}"
        echo ""
        echo "${BLUE}🧪 جاهز للتحويل النص إلى صوت!${NC}"
        echo ""
    else
        echo "${RED}❌ الخدمة فشلت في التشغيل${NC}"
        echo "${YELLOW}💡 تحقق من السجلات: tail -f /tmp/elevenlabs-service.log${NC}"
        exit 1
    fi
}

# ==============
# تحويل النص إلى صوت
# ==============

convert_text_to_speech() {
    local text="$1"
    
    if [ -z "$text" ]; then
        echo "${RED}❌ يجب إدخال نص${NC}"
        exit 1
    fi
    
    echo "${BLUE}🎤 تحويل: ${text}${NC}"
    echo ""
    
    # تحويل النص (إضافة مسافة بعد الفواصل)
    formatted_text=$(echo "$text" | sed 's/،/، /g' | sed 's/\./. /g')
    
    # استدعاء API
    response=$(curl -s -X POST "http://localhost:${API_PORT}/api/text-to-speech" \
        -H "Content-Type: application/json" \
        -d "{\"text\": \"$formatted_text\"}")
    
    if [ $? -eq 0 ]; then
        # استخراج اسم الملف
        filename=$(echo "$response" | grep -oP -m1 '"filename"' | sed 's/[^"]*"\([^"]*\)".*/\1/')
        
        if [ ! -z "$filename" ]; then
            echo "${GREEN}✅ تم التحويل!${NC}"
            echo "${YELLOW}📁 اسم الملف: $filename${NC}"
            echo "${YELLOW}📁 مسار الملف: $API_SERVICE_DIR/output/$filename${NC}"
            echo "${YELLOW}📱 رابط التحميل: http://localhost:${API_PORT}/output/$filename${NC}"
            
            # محاكاة إرسال إلى تيليغرام
            echo ""
            echo "${BLUE}📱 للإرسال على تيليغرام:${NC}"
            echo "${CYAN}  1. افتح: http://localhost:${API_PORT}/output/$filename${NC}"
            echo "${CYAN}  2. قم بتنزيل الملف${NC}"
            echo "${CYAN}  3. افتح تيليغرام واختر المحادثة${NC}"
            echo "${CYAN}  4. أرسل الملف كرسالة صوتية${NC}"
        else
            echo "${RED}❌ فشل التحويل${NC}"
            echo "${YELLOW}💡 تأكد من تشغيل الخدمة${NC}"
        fi
    else
        echo "${RED}❌ خطأ في الاتصال بالخدمة${NC}"
    fi
}

# ==============
# اختبار الخدمة
# ==============

test_service() {
    echo "${BLUE}🧪 اختبار خدمة ElevenLabs...${NC}"
    echo ""
    
    # اختبار 1: فحص الصحة
    echo "${YELLOW}1️⃣  فحص الصحة...${NC}"
    if curl -s http://localhost:${API_PORT}/api/health; then
        echo "${GREEN}✅ الصحة: OK${NC}"
    else
        echo "${RED}❌ الصحة: غير جاهز${NC}"
    fi
    
    # اختبار 2: التحويل
    echo "${YELLOW}2️⃣ اختبار التحويل...${NC}"
    response=$(curl -s -X POST "http://localhost:${API_PORT}/api/text-to-speech" \
        -H "Content-Type: application/json" \
        -d "{\"text\": \"مرحباً بك\"}")
    
    if [ $? -eq 0 ]; then
        echo "${GREEN}✅ التحويل: يعمل${NC}"
    else
        echo "${RED}❌ التحويل: غير جاهز${NC}"
    fi
    
    # اختبار 3: قائمة الأصوات
    echo "${YELLOW}3️⃣ قائمة الأصوات...${NC}"
    voices=$(curl -s "http://localhost:${API_PORT}/api/voices" | grep -oP -m1 "total")
    echo "${CYAN}عدد الأصوات: $voices${NC}"
    
    echo ""
    echo "${GREEN}✅ اختبار مكتمل${NC}"
}

# ==============
# إيقاف الخدمة
# ==============

stop_service() {
    echo "${BLUE}🛑 إيقاف خدمة ElevenLabs...${NC}"
    echo ""
    
    # قراءة PID
    if [ -f /tmp/elevenlabs-service.pid ]; then
        pid=$(cat /tmp/elevenlabs-service.pid)
        kill $pid 2>/dev/null
        rm /tmp/elevenlabs-service.pid
        echo "${GREEN}✅ تم إيقاف الخدمة (PID: $pid)${NC}"
    else
        echo "${YELLOW}⚠️  لم يتم العثور على PID${NC}"
    fi
    
    # التحقق من التوقف
    sleep 2
    if ! curl -s http://localhost:${API_PORT}/api/health; then
        echo "${GREEN}✅ الخدمة متوقفة${NC}"
    else
        echo "${YELLOW}⚠️ الخدمة لا تزال تعمل${NC}"
    fi
}

# ==============
# حالة الخدمة
# ==============

show_status() {
    echo "${BLUE}📊 حالة خدمة ElevenLabs${NC}"
    echo ""
    
    # فحص PID
    if [ -f /tmp/elevenlabs-service.pid ]; then
        pid=$(cat /tmp/elevenlabs-service.pid)
        
        # التحقق من العملية
        if ps -p $pid > /dev/null 2>&1; then
            echo "${GREEN}✅ حالة: قيد التشغيل${NC}"
            echo "${YELLOW}🔢 PID: $pid${NC}"
            
            # فحص المنفذ
            if netstat -an 2>/dev/null | grep -q ":${API_PORT}"; then
                echo "${GREEN}✅ المنفذ ${API_PORT}: مفتوح${NC}"
            else
                echo "${YELLOW}⚠️ المنفذ ${API_PORT}: مغلق${NC}"
            fi
        else
            echo "${RED}❌ العملية غير موجودة${NC}"
            rm /tmp/elevenlabs-service.pid
    else
        echo "${YELLOW}⚠️  الخدمة غير مشغلة${NC}"
    fi
    
    echo ""
    
    # فحص API
    if curl -s http://localhost:${API_PORT}/api/health; then
        echo "${GREEN}✅ API: متاح${NC}"
        echo "${GREEN}🌐 http://localhost:${API_PORT}${NC}"
    else
        echo "${RED}❌ API: غير متاح${NC}"
    fi
    
    echo ""
    echo "${YELLOW}💡 لعرض السجلات:${NC}"
    echo "tail -f /tmp/elevenlabs-service.log"
}

# ==============
# سجلات الخدمة
# ==============

show_logs() {
    echo "${BLUE}📋 سجلات خدمة ElevenLabs${NC}"
    echo "${CYAN}═════════════════════════════════════════${NC}"
    echo ""
    
    if [ ! -f /tmp/elevenlabs-service.log ]; then
        echo "${YELLOW}⚠️ لا توجد سجلات${NC}"
        exit 0
    fi
    
    tail -n 50 /tmp/elevenlabs-service.log
}

# ==============
# فحص الصحة
# ==============

check_health() {
    echo "${BLUE}🏥 فحص صحة الخدمة${NC}"
    echo ""
    
    if curl -s http://localhost:${API_PORT}/api/health; then
        echo "${GREEN}✅ الخدمة تعمل${NC}"
        echo "${CYAN}Response: $(curl -s http://localhost:${API_PORT}/api/health)${NC}"
    else
        echo "${RED}❌ الخدمة غير متاحة${NC}"
        echo "${YELLOW}💡 تأكد من تشغيلها: ./workflow.sh start${NC}"
    fi
}

# ==============
# القائمة الرئيسية
# ==============

# تحقق من المعاملات
command="${1:-help}"

case "$command" in
    help|--help|-h)
        show_help
        ;;
        
    start)
        check_dependencies
        start_service
        ;;
        
    convert)
        check_dependencies
        convert_text_to_speech "$@"
        ;;
        
    test)
        check_dependencies
        test_service
        ;;
        
    stop)
        stop_service
        ;;
        
    status)
        show_status
        ;;
        
    logs)
        show_logs
        ;;
        
    health)
        check_health
        ;;
        
    *)
        echo "${RED}❌ أمر غير معروف${NC}"
        echo "${YELLOW}💡 استخدم: ./workflow.sh help${NC}"
        exit 1
        ;;
esac
