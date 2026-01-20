#!/bin/bash

# MT5 Docker Auto-Restore Script
# يسترجع الـ backup تلقائياً عند أول تشغيل إذا كان الـ Volume فارغاً

set -e

WINEPREFIX="${WINEPREFIX:-/root/.wine}"
CONFIG_FILE="/opt/mt5/config.env"
BACKUP_DIR="/opt/mt5/backups"
RESTORE_MARKER="$WINEPREFIX/.mt5_restored"

echo "==========================================" 
echo "   MT5 Auto-Restore Check"
echo "==========================================="

# التحقق من وجود MT5 مثبت مسبقاً
if [ -f "$RESTORE_MARKER" ]; then
    echo "✅ تم الاسترجاع سابقاً - تخطي"
    exit 0
fi

# التحقق من وجود MT5 terminal
MT5_EXISTS=$(find "$WINEPREFIX/drive_c/Program Files" -name "terminal*.exe" 2>/dev/null | head -1)
if [ -n "$MT5_EXISTS" ]; then
    echo "✅ MT5 موجود بالفعل - تخطي الاسترجاع"
    touch "$RESTORE_MARKER"
    exit 0
fi

echo "⚠️  MT5 غير موجود - محاولة الاسترجاع..."

# الخيار 1: الاسترجاع من ملف محلي في مجلد backups
LOCAL_BACKUP=$(ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null | head -1)
if [ -n "$LOCAL_BACKUP" ] && [ -f "$LOCAL_BACKUP" ]; then
    echo "📦 وُجد backup محلي: $(basename "$LOCAL_BACKUP")"
    echo "🔄 جاري الاسترجاع..."
    
    mkdir -p "$WINEPREFIX"
    tar xzf "$LOCAL_BACKUP" -C "$WINEPREFIX"
    
    echo "✅ تم الاسترجاع من الملف المحلي!"
    touch "$RESTORE_MARKER"
    exit 0
fi

# الخيار 2: الاسترجاع من رابط خارجي
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

if [ -n "$BACKUP_URL" ]; then
    echo "📥 تحميل backup من: $BACKUP_URL"
    
    TEMP_BACKUP="/tmp/mt5_backup.tar.gz"
    
    # تحميل الملف
    if wget -q --show-progress -O "$TEMP_BACKUP" "$BACKUP_URL"; then
        echo "🔄 جاري الاسترجاع..."
        
        mkdir -p "$WINEPREFIX"
        tar xzf "$TEMP_BACKUP" -C "$WINEPREFIX"
        rm -f "$TEMP_BACKUP"
        
        echo "✅ تم الاسترجاع من الرابط الخارجي!"
        touch "$RESTORE_MARKER"
        exit 0
    else
        echo "❌ فشل تحميل الـ backup"
    fi
fi

echo ""
echo "ℹ️  لا يوجد backup متاح - سيتم تثبيت MT5 جديد"
echo "   لاستخدام الاسترجاع التلقائي:"
echo "   1. ضع ملف backup في مجلد /opt/mt5/backups/"
echo "   2. أو أضف BACKUP_URL في config.env"
echo ""

exit 0
