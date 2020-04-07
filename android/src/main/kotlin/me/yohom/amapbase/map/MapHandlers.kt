package me.yohom.amapbase.map

import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.util.Log
import com.amap.api.maps.*
import com.amap.api.maps.model.CameraPosition
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.LatLngBounds
import com.amap.api.maps.model.Marker
import com.amap.api.maps.model.animation.Animation
import com.amap.api.maps.model.animation.ScaleAnimation
import com.amap.api.maps.offlinemap.OfflineMapActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import me.yohom.amapbase.AMapBasePlugin
import me.yohom.amapbase.AMapBasePlugin.Companion.registrar
import me.yohom.amapbase.MapMethodHandler
import me.yohom.amapbase.common.log
import me.yohom.amapbase.common.parseFieldJson
import me.yohom.amapbase.common.toFieldJson
import java.io.*
import java.util.*

val beijingLatLng = LatLng(39.941711, 116.382248)
val markerAnimation: Animation = ScaleAnimation(0f, 1f, 0f, 1f) //初始化生长效果动画

object SetCustomMapStyleID : MapMethodHandler {
    private lateinit var map: AMap

    override fun with(map: AMap): MapMethodHandler {
        this.map = map
        return this
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val styleId = call.argument("styleId") ?: ""

        log("方法map#setCustomMapStyleID android端参数: styleId -> $styleId")

        map.setCustomMapStyleID(styleId)

        result.success(success)
    }
}

object SetCustomMapStylePath : MapMethodHandler {

    private lateinit var map: AMap

    override fun with(map: AMap): SetCustomMapStylePath {
        this.map = map
        return this
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val path = call.argument("path") ?: ""

        log("方法map#setCustomMapStylePath android端参数: path -> $path")

        var outputStream: FileOutputStream? = null
        var inputStream: InputStream? = null
        val filePath: String?
        try {
            inputStream = registrar.context().assets.open(registrar.lookupKeyForAsset(path))
            val b = ByteArray(inputStream!!.available())
            inputStream.read(b)

            filePath = registrar.context().filesDir.absolutePath
            val file = File("$filePath/$path")
            if (file.exists()) {
                file.delete()
            }

            if (!file.parentFile.exists()) {
                file.parentFile.mkdirs()
            }
            file.createNewFile()
            outputStream = FileOutputStream(file)
            outputStream.write(b)
        } catch (e: IOException) {
            result.error(e.message, e.localizedMessage, e.printStackTrace())
            return
        } finally {
            inputStream?.close()
            outputStream?.close()
        }

        map.setCustomMapStylePath("$filePath/$path")

        result.success(success)
    }
}

object SetMapCustomEnable : MapMethodHandler {

    private lateinit var map: AMap

    override fun with(map: AMap): SetMapCustomEnable {
        this.map = map
        return this
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val enabled = call.argument("enabled") ?: false

        log("方法map#setMapCustomEnable android端参数: enabled -> $enabled")

        map.setMapCustomEnable(enabled)

        result.success(success)
    }
}

object ConvertCoordinate : MapMethodHandler {

    lateinit var map: AMap

    private val types = arrayListOf(
            CoordinateConverter.CoordType.GPS,
            CoordinateConverter.CoordType.BAIDU,
            CoordinateConverter.CoordType.MAPBAR,
            CoordinateConverter.CoordType.MAPABC,
            CoordinateConverter.CoordType.SOSOMAP,
            CoordinateConverter.CoordType.ALIYUN,
            CoordinateConverter.CoordType.GOOGLE
    )

    override fun with(map: AMap): ConvertCoordinate {
        this.map = map
        return this
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val lat = call.argument<Double>("lat")!!
        val lon = call.argument<Double>("lon")!!
        val typeIndex = call.argument<Int>("type")!!
        val amapCoordinate = CoordinateConverter(AMapBasePlugin.registrar.context())
                .from(types[typeIndex])
                .coord(LatLng(lat, lon, false))
                .convert()

        result.success(amapCoordinate.toFieldJson())
    }
}

object CalcDistance : MapMethodHandler {
    lateinit var map: AMap

    override fun with(map: AMap): CalcDistance {
        this.map = map
        return this
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val p1 = call.argument<Map<String, Any>>("p1")
        val p2 = call.argument<Map<String, Any>>("p2")
        val latlng1 = p1!!.getLntlng()
        val latlng2 = p2!!.getLntlng()
        val dis = AMapUtils.calculateLineDistance(latlng1, latlng2)
        result.success(dis)
    }

    private fun Map<String, Any>.getLntlng(): LatLng {
        val lat = get("latitude") as Double
        val lng = get("longitude") as Double
        return LatLng(lat, lng)
    }
}

object ClearMap : MapMethodHandler {

    lateinit var map: AMap

    override fun with(map: AMap): ClearMap {
        this.map = map
        return this
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        map.clear()

        result.success(success)
    }
}

object OpenOfflineManager : MapMethodHandler {

    override fun onMethodCall(p0: MethodCall, p1: MethodChannel.Result) {
        AMapBasePlugin.registrar.activity().startActivity(
                Intent(AMapBasePlugin.registrar.activity(),
                        OfflineMapActivity::class.java)
        )
    }

    override fun with(map: AMap): MapMethodHandler {
        return this
    }

}

object SetLanguage : MapMethodHandler {

    lateinit var map: AMap

    override fun with(map: AMap): SetLanguage {
        this.map = map
        return this
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val language = call.argument<String>("language") ?: "0"

        log("方法map#setLanguage android端参数: language -> $language")

        map.setMapLanguage(language)

        result.success(success)
    }
}

object SetMapType : MapMethodHandler {

    lateinit var map: AMap

    override fun with(map: AMap): SetMapType {
        this.map = map
        return this
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val mapType = call.argument<Int>("mapType") ?: 1

        log("方法map#setMapType android端参数: mapType -> $mapType")

        map.mapType = mapType

        result.success(success)
    }
}

object SetMyLocationStyle : MapMethodHandler {

    lateinit var map: AMap

    override fun with(map: AMap): SetMyLocationStyle {
        this.map = map
        return this
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val styleJson = call.argument<String>("myLocationStyle") ?: "{}"

        log("方法setMyLocationEnabled android端参数: styleJson -> $styleJson")

        styleJson.parseFieldJson<UnifiedMyLocationStyle>().applyTo(map)

        result.success(success)
    }
}

object SetUiSettings : MapMethodHandler {

    lateinit var map: AMap

    override fun with(map: AMap): SetUiSettings {
        this.map = map
        return this
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val uiSettingsJson = call.argument<String>("uiSettings") ?: "{}"

        log("方法setUiSettings android端参数: uiSettingsJson -> $uiSettingsJson")

        uiSettingsJson.parseFieldJson<UnifiedUiSettings>().applyTo(map)

        result.success(success)
    }
}

object ShowIndoorMap : MapMethodHandler {

    lateinit var map: AMap

    override fun with(map: AMap): ShowIndoorMap {
        this.map = map
        return this
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val enabled = call.argument<Boolean>("showIndoorMap") ?: false

        log("方法map#showIndoorMap android端参数: enabled -> $enabled")

        map.showIndoorMap(enabled)

        result.success(success)
    }
}

object AddMarker : MapMethodHandler {

    lateinit var map: AMap

    override fun with(map: AMap): AddMarker {
        this.map = map
        return this
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val optionsJson = call.argument<String>("markerOptions") ?: "{}"
        val lockedToScreen = call.argument<Boolean>("lockedToScreen") ?: false
        val openAnimation = call.argument<Boolean>("openAnimation") ?: true
        log("方法marker#addMarker android端参数: optionsJson -> $optionsJson")

        val unifiedMarkerOptions = optionsJson.parseFieldJson<UnifiedMarkerOptions>()
        unifiedMarkerOptions.applyTo(map = map, lockedToScreen = lockedToScreen, openAnimation = openAnimation)

        result.success(success)
    }
}

object AddMarkers : MapMethodHandler {

    lateinit var map: AMap

    var markers: MutableList<Marker> = ArrayList()
    var pointList: MutableList<LatLng> = ArrayList()

    override fun with(map: AMap): AddMarkers {
        this.map = map
        return this
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val moveToCenter = call.argument<Boolean>("moveToCenter") ?: false
        val optionsListJson = call.argument<String>("markerOptionsList") ?: "[]"
        val clear = call.argument<Boolean>("clear") ?: false // Is clear all the markers on screen
        val clearLast = call.argument<Boolean>("clearLast") ?: false  // Is clear last added markers
        val openAnimation = call.argument<Boolean>("openAnimation") ?: true
        log("方法marker#addMarkers android端参数: optionsListJson -> $optionsListJson")
        val optionsList = ArrayList(optionsListJson.parseFieldJson<List<UnifiedMarkerOptions>>().map { it.toMarkerOption() })

        if (clear) {
            map.mapScreenMarkers.forEach { it.remove() }
            pointList.clear()
        }
        if (clearLast && markers.size > 0) {
            for (marker in markers) {
                marker.remove()
            }
            pointList.clear()
        }
        markers.addAll(map.addMarkers(optionsList, moveToCenter))
        for (marker in markers) {
            pointList.add(marker.position)
            if (openAnimation) {
                marker.setAnimation(markerAnimation)
                marker.startAnimation()
            }
        }
        ///Zoom to let all marker in screen without change current center
//        if (zoomToSpanCenter && pointList.size > 0) {
//            log("map.cameraPosition.target: ${map.cameraPosition.target}")
//            val bounds = getLatLngBounds(map.cameraPosition.target, pointList)
//            changeCamera(map, CameraUpdateFactory.newLatLngBounds(bounds, 50))
//        }
        result.success(success)
    }
}

fun dp2px(paramContext: Context, paramFloat: Float): Int {
    return (0.5f + paramFloat * paramContext.resources.displayMetrics.density).toInt()
}


/**
 * 根据动画按钮状态，调用函数animateCamera或moveCamera来改变可视区域
 * @param update 新的位置
 * @param isRefresh 移动后是否刷新点位列表
 */
private fun changeCamera(map: AMap, update: CameraUpdate) {
    map.animateCamera(update)
}

/**
 * 根据中心点和自定义内容获取缩放bounds
 */
private fun getLatLngBounds(centerpoint: LatLng?, pointList: List<LatLng>): LatLngBounds {

    val b = LatLngBounds.builder()
    if (centerpoint != null) {
        for (i in pointList.indices) {
            val p = pointList[i]
            val p1 = LatLng(centerpoint.latitude * 2 - p.latitude, centerpoint.longitude * 2 - p.longitude)
            b.include(p)
            b.include(p1)
        }
    }
    return b.build()
}


object AddPolyline : MapMethodHandler {
    lateinit var map: AMap

    override fun with(map: AMap): MapMethodHandler {
        this.map = map
        return this
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val options = call.argument<String>("options")?.parseFieldJson<UnifiedPolylineOptions>()

        log("map#AddPolyline android端参数: options -> $options")

        options?.applyTo(map)

        result.success(success)
    }
}

object ClearMarker : MapMethodHandler {

    lateinit var map: AMap

    override fun with(map: AMap): ClearMarker {
        this.map = map
        return this
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        map.mapScreenMarkers.forEach { it.remove() }

        result.success(success)
    }
}

object ChangeLatLng : MapMethodHandler {

    lateinit var map: AMap

    override fun with(map: AMap): ChangeLatLng {
        this.map = map
        return this
    }

    override fun onMethodCall(methodCall: MethodCall, methodResult: MethodChannel.Result) {
        val targetJson = methodCall.argument<String>("target") ?: "{}"

        map.animateCamera(CameraUpdateFactory.changeLatLng(targetJson.parseFieldJson<LatLng>()))

        methodResult.success(success)
    }
}

object GetCenterLnglat : MapMethodHandler {
    lateinit var map: AMap
    override fun with(map: AMap): MapMethodHandler {
        this.map = map
        return this
    }

    override fun onMethodCall(methodCall: MethodCall, methodResult: MethodChannel.Result) {
        val target = map.cameraPosition.target
        methodResult.success(target.toFieldJson())
    }
}

object SetMapStatusLimits : MapMethodHandler {

    lateinit var map: AMap

    override fun with(map: AMap): SetMapStatusLimits {
        this.map = map
        return this
    }

    override fun onMethodCall(methodCall: MethodCall, methodResult: MethodChannel.Result) {
        val swLatLng: LatLng? = methodCall.argument<String>("swLatLng")?.parseFieldJson()
        val neLatLng: LatLng? = methodCall.argument<String>("neLatLng")?.parseFieldJson()

        map.setMapStatusLimits(LatLngBounds(swLatLng, neLatLng))

        methodResult.success(success)
    }
}

object SetPosition : MapMethodHandler {

    lateinit var map: AMap

    override fun with(map: AMap): SetPosition {
        this.map = map
        return this
    }

    override fun onMethodCall(methodCall: MethodCall, methodResult: MethodChannel.Result) {
        val target: LatLng = methodCall.argument<String>("target")?.parseFieldJson()
                ?: beijingLatLng
        val zoom: Double = methodCall.argument<Double>("zoom") ?: 10.0
        val tilt: Double = methodCall.argument<Double>("tilt") ?: 0.0
        val bearing: Double = methodCall.argument<Double>("bearing") ?: 0.0

        map.moveCamera(CameraUpdateFactory.newCameraPosition(CameraPosition(target, zoom.toFloat(), tilt.toFloat(), bearing.toFloat())))

        methodResult.success(success)
    }
}

object SetZoomLevel : MapMethodHandler {

    lateinit var map: AMap

    override fun with(map: AMap): SetZoomLevel {
        this.map = map
        return this
    }

    override fun onMethodCall(methodCall: MethodCall, methodResult: MethodChannel.Result) {
        val zoomLevel = methodCall.argument<Int>("zoomLevel") ?: 15

        map.moveCamera(CameraUpdateFactory.zoomTo(zoomLevel.toFloat()))

        methodResult.success(success)
    }
}

object ZoomToSpan : MapMethodHandler {

    lateinit var map: AMap

    override fun with(map: AMap): ZoomToSpan {
        this.map = map
        return this
    }

    override fun onMethodCall(methodCall: MethodCall, methodResult: MethodChannel.Result) {
        val boundJson = methodCall.argument<String>("bound") ?: "[]"
        val padding = methodCall.argument<Int>("padding") ?: 80
        val isMoveCenter = methodCall.argument<Boolean>("isMoveCenter") ?: true

        if (isMoveCenter) {
            val bounds = getLatLngBounds(map.cameraPosition.target, boundJson.parseFieldJson<List<LatLng>>())
            changeCamera(map, CameraUpdateFactory.newLatLngBounds(bounds, 50))
        } else {
            map.moveCamera(CameraUpdateFactory.newLatLngBounds(
                    LatLngBounds.builder().run {
                        boundJson.parseFieldJson<List<LatLng>>().forEach {
                            include(it)
                        }
                        build()
                    },
                    padding
            ))
        }
        methodResult.success(success)
    }
}

object ScreenShot : MapMethodHandler {
    lateinit var map: AMap
    override fun with(map: AMap): MapMethodHandler {
        this.map = map
        return this
    }

    override fun onMethodCall(methodCall: MethodCall, methodResult: MethodChannel.Result) {
        map.getMapScreenShot(object : AMap.OnMapScreenShotListener {
            override fun onMapScreenShot(bitmap: Bitmap?) {
            }

            override fun onMapScreenShot(bitmap: Bitmap?, status: Int) {
                if (bitmap == null) {
                    methodResult.error("截图失败", null, null)
                    return
                }
                if (status != 0) {
                    val outputStream = ByteArrayOutputStream()
                    bitmap.compress(Bitmap.CompressFormat.JPEG, 100, outputStream)
                    methodResult.success(outputStream.toByteArray())
                } else {
                    methodResult.error("截图失败,渲染未完成", "截图失败,渲染未完成", null)
                }
            }
        })
    }
}
