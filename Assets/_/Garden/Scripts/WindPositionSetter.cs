using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Es.InkPainter.Sample;
using Es.InkPainter;

namespace PT.Garden
{
    public class WindPositionSetter : MousePainter
    {
        public bool doJob = false;

        [SerializeField] private MousePainter _mousePainter;
        [SerializeField] private InkCanvas _canvas;

        private void Update(){
            if(doJob){
                //_canvas.Paint(brush, _mousePainter.lastPoint);
            }
        }
    }
}