import { Map, View } from 'ol';
import TileLayer from 'ol/layer/Tile';
import TileWMS from 'ol/source/TileWMS';
import XYZ from 'ol/source/XYZ';
import { transform } from 'ol/proj';
import { getBottomLeft, getTopRight } from 'ol/extent';
import Point from 'ol/geom/Point';
import Feature from 'ol/Feature';
import VectorSource from 'ol/source/Vector';
import VectorLayer from 'ol/layer/Vector';

// Calling API on our own backend, downloading and saving map tile images, then serving them would hide these keys
// but will incur network costs that we're not willing to pay at the moment, so the keys are exposed to the public.
const DEFAULT_CENTER_COORDINATE = [127.05488, 37.27538]
const VWORLD_API_KEY = 'B1E465C1-3237-368E-8ACF-AA0E89EA8C43'
const VWORLD_DOMAIN = 'http://localhost:4000'
const VWORLD_WMS_URL = `https://api.vworld.kr/req/wms?KEY=${VWORLD_API_KEY}&DOMAIN=${encodeURIComponent(VWORLD_DOMAIN)}`
const VWORLD_WMTS_URL = `https://api.vworld.kr/req/wmts/1.0.0/${VWORLD_API_KEY}/Base/{z}/{y}/{x}.png`
const SAFEMAP_API_KEY = 'CD1CCFGI-CD1C-CD1C-CD1C-CD1CCFGI4Z'
const SAFEMAP_URL = `https://www.safemap.go.kr/openApiService/wms/getLayerData.do?apikey=${SAFEMAP_API_KEY}`
const FOREST_FIRE_LAYER_NAME = 'forestFire'
const BASE_LAYER_NAME = 'base'
const DISASTER_WARNING_LAYER_NAME = 'disasterWarning'
const FLOOD_LAYER_NAME = 'flood'
const CIVIL_DEFENSE_SHELTERS_LAYER_NAME = 'civilDefenseShelters'
const CIVIL_DEFENSE_WATER_SOURCES_LAYER_NAME = 'civilDefenseWaterSources'
const MAP_LAYER_KEYS = [
  FOREST_FIRE_LAYER_NAME,
  DISASTER_WARNING_LAYER_NAME,
  FLOOD_LAYER_NAME,
]
const MARKER_LAYER_KEYS = [
  CIVIL_DEFENSE_SHELTERS_LAYER_NAME,
  CIVIL_DEFENSE_WATER_SOURCES_LAYER_NAME,
]

const forestFireLayer = new TileLayer({
  source: new TileWMS({
    url: VWORLD_WMS_URL,
    params: {
      LAYERS: ['lt_c_kfdrssigugrade'],
      STYLES: 'lt_c_kfdrssigugrade',
      VERSION: '1.3.0',
    },
    serverType: 'geoserver',
  }),
  name: FOREST_FIRE_LAYER_NAME
})

const floodLayer = new TileLayer({
  source: new TileWMS({
    url: SAFEMAP_URL,
    params: {
      LAYERS: ['A2SM_FLUDEXPECT_22'],
      VERSION: '1.1.1',
    },
    serverType: 'geoserver'
  }),
  name: FLOOD_LAYER_NAME
})

const disasterWarningLayer = new TileLayer({
  source: new TileWMS({
    url: VWORLD_WMS_URL,
    params: {
      LAYERS: ['lt_c_up201'],
      STYLES: 'lt_c_up201',
      VERSION: '1.3.0',
    },
    serverType: 'geoserver',
  }),
  name: DISASTER_WARNING_LAYER_NAME
})

const vworldBaseLayer = new TileLayer({
  source: new XYZ({ url: VWORLD_WMTS_URL }),
  minZoom: 5,
  maxZoom: 19,
  name: BASE_LAYER_NAME
});

const LAYERS_MAP = {
  [FLOOD_LAYER_NAME]: floodLayer,
  [DISASTER_WARNING_LAYER_NAME]: disasterWarningLayer,
  [FOREST_FIRE_LAYER_NAME]: forestFireLayer,
}

function getCenterCoordinate() {
  if (navigator && navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(geolocationPosition => {
      return [geolocationPosition.coords.longitude, geolocationPosition.coords.latitude]
    }, _geolocationPositionError => {
      return DEFAULT_CENTER_COORDINATE
    })
    return DEFAULT_CENTER_COORDINATE
  } else {
    return DEFAULT_CENTER_COORDINATE
  }
}

function transformCoordinate(coordinate) {
  return transform(coordinate, 'EPSG:4326', 'EPSG:3857')
}

const center = transformCoordinate(getCenterCoordinate())

const view = new View({
  center: center,
  zoom: 10
})
let map

const layers =
  [
    vworldBaseLayer,
    forestFireLayer,
    floodLayer,
    disasterWarningLayer
  ]

window.addEventListener("phx:page-loading-stop", _ => {
  map = new Map({
    target: 'map',
    layers: layers,
    view: view
  });
  map.on('moveend', onMoveEnd);
})

window.addEventListener("phx:toggle-layer", (payload) => {
  const layerKey = payload.detail.layer
  const shouldShow = payload.detail.shouldShow
  if (MAP_LAYER_KEYS.includes(layerKey)) {
    if (shouldShow) {
      map.addLayer(LAYERS_MAP[layerKey])
    } else {
      const targetLayer = map.getLayers().getArray().filter(l => l.get('name') === layerKey)[0]
      if (targetLayer) {
        map.removeLayer(targetLayer)
      }
    }
  } else if (MARKER_LAYER_KEYS.includes(layerKey)) {
    if (shouldShow) {
      const items = payload.detail.items
      const vectorSource = new VectorSource({})
      const vectorLayer = new VectorLayer({
        source: vectorSource,
        name: layerKey
      })
      const pointFeatures = items.map(i => {
        return new Feature({
          geometry: new Point([i.x_epsg_3857, i.y_epsg_3857])
        })
      })
      vectorSource.addFeatures(pointFeatures)
      map.addLayer(vectorLayer)
    } else {
      const targetLayer = map.getLayers().getArray().filter(l => l.get('name') === layerKey)[0]
      if (targetLayer) {
        map.removeLayer(targetLayer)
      }
    }
  }
})

function onMoveEnd(evt) {
  const map = evt.map
  const view = map.getView()
  const extent = view.calculateExtent(map.getSize());
  const bottomLeft = getBottomLeft(extent);
  const topRight = getTopRight(extent);
  const center = view.getCenter()
  const event = new CustomEvent('escape-disaster:update-map-info', { detail: { bottomLeft, topRight, center } });
  document.getElementById('map-container').dispatchEvent(event);
}

export const MapHook = {
  mounted() {
    this.el.addEventListener('escape-disaster:update-map-info', info => {
      const detail = info.detail
      this.pushEvent('update-map-info', { bottomLeft: detail.bottomLeft, topRight: detail.topRight, center: detail.center })
    });
  }
}
