using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Es.InkPainter;

namespace PT.Garden
{
    public class GrassPatchActivator : MonoBehaviour
    {
        public struct PixelChange
        {
            public float x;
            public float y;
            public float change;
            public float r;
            public float g;
            public float b;
        }

        public ComputeShader computeShader;
        public PixelChange[] results;

        [SerializeField] private GameObject grassParticle;
        [SerializeField] private Transform uv00, uv11;
        private ParticleSystem[] particlePool;
        private int particleIndex = 0;
        [SerializeField] private InkCanvas _removeCanvas, _windCanvas;
        [SerializeField] private MeshRenderer _mr;
        private bool _hasBeeIn = false, _hasCopy = false;
        public RenderTexture renderTexture;
        public RenderTexture lastRenderTexture;
        public RenderTexture grassTexture;
        private ComputeBuffer resultsBFF;
        private bool _isSetUp = false;

        private void Start()
        {
            _isSetUp = _mr != null;

            if (_isSetUp)
            {
                particlePool = new ParticleSystem[40];
                for (int i = 0; i < 40; i++)
                {
                    particlePool[i] = Instantiate(grassParticle).GetComponent<ParticleSystem>();
                    particlePool[i].transform.parent = transform;
                    particlePool[i].gameObject.SetActive(false);
                }

                Material _mainMaterial = _mr.materials[0];

                int _txid = Shader.PropertyToID("_NoGrassTex");
                renderTexture = (RenderTexture)_mainMaterial.GetTexture(_txid);

                _txid = Shader.PropertyToID("_GrassTex");
                Texture grassTxt = _mainMaterial.GetTexture(_txid);
                grassTexture = CopyTexture(grassTxt);

                results = new PixelChange[renderTexture.width * renderTexture.height];
                resultsBFF = new ComputeBuffer(
                    results.Length,
                    sizeof(float) * 6
                );
            }
        }

        private void DoParticle(Vector3 position, Color c)
        {
            ParticleSystem p = particlePool[particleIndex];
            particleIndex = (particleIndex + 1) % 40;
            p.startColor = c;
            p.gameObject.SetActive(true);
            p.Stop();
            p.Play();
            p.transform.position = position;
            p.transform.forward = Vector3.up;
        }

        private void OnTriggerEnter(Collider other)
        {
            try
            {
                PositionPainter p = other.GetComponent<PositionPainter>();
                if (p != null)
                {
                    _hasBeeIn = true;
                    p._removeCanvas = _removeCanvas;
                    p._bendCanvas = _windCanvas;
                    p._isPainting = true;
                }
            }
            catch { }
        }

        private void OnTriggerExit(Collider other)
        {
            try
            {
                PositionPainter p = other.GetComponent<PositionPainter>();
                if (p != null)
                {
                    _hasBeeIn = false;
                    _hasCopy = false;
                    p._isPainting = false;
                }
            }
            catch { }
        }

        private void Update()
        {
            if (_isSetUp && _hasBeeIn)
            {
                if (!_hasCopy)
                {
                    lastRenderTexture = CopyTexture(renderTexture);
                    _hasCopy = true;
                }
                else
                {
                    RenderTexture curRT = CopyTexture(renderTexture);

                    computeShader.SetBuffer(0, "results", resultsBFF);
                    computeShader.SetFloat("width", curRT.width);
                    computeShader.SetFloat("txtW", grassTexture.width);
                    computeShader.SetFloat("txtH", grassTexture.height);
                    computeShader.SetTexture(0, "GrassTXT", grassTexture);
                    computeShader.SetTexture(0, "InputTXT", curRT);
                    computeShader.SetTexture(0, "LastInputTXT", lastRenderTexture);

                    computeShader.Dispatch(0, curRT.width / 8, curRT.height / 8, 1);
                    resultsBFF.GetData(results);

                    lastRenderTexture = curRT;
                    foreach (PixelChange pt in results)
                    {
                        if (Mathf.Abs(pt.change) > 0.1)
                        {
                            Vector3 pos = new Vector3();
                            pos.x = (pt.x / curRT.width) * (uv11.position.x - uv00.position.x) + uv00.position.x;
                            pos.z = (pt.y / curRT.height) * (uv11.position.z - uv00.position.z) + uv00.position.z;
                            pos.y = transform.position.y + 0.5f;
                            DoParticle(pos, new Color(pt.r, pt.g, pt.b));
                        }
                    }
                }
            }
        }

        private RenderTexture CopyTexture(RenderTexture t)
        {
            RenderTexture newrt = new RenderTexture(t);
            newrt.enableRandomWrite = true;
            newrt.Create();

            Graphics.Blit(t, newrt);
            return newrt;
        }

        private RenderTexture CopyTexture(Texture t)
        {
            RenderTexture newrt = new RenderTexture(t.width, t.height, 1, UnityEngine.Experimental.Rendering.DefaultFormat.LDR);
            newrt.enableRandomWrite = true;
            newrt.Create();

            Graphics.Blit(t, newrt);
            return newrt;
        }
    }
}